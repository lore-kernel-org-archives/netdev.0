From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH net-next 1/2] wireless: Remove casts of void *
Date: Tue, 14 Jun 2011 01:45:07 -0700
Message-ID: <477F20668A386D41ADCC57781B1F704307FF7C464F@SC-VEXCH1.marvell.com>
References: <cover.1308024069.git.joe@perches.com>
 <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
 <BANLkTi=i30Rn7gpCDbn9KKJucq8CB=hssA@mail.gmail.com>
 <1308029532.26699.68.camel@Joe-Laptop>,<BANLkTik4fWbCc8pRZfKCzvKD2f6sK9QCEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:49194 "EHLO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755310Ab1FNIqB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 04:46:01 -0400
In-Reply-To: <BANLkTik4fWbCc8pRZfKCzvKD2f6sK9QCEw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
>> @@ -191,7 +191,7 @@ int mwifiex_ret_11n_cfg(struct host_cmd_ds_command *resp, void *data_buf)
>>        struct host_cmd_ds_11n_cfg *htcfg = &resp->params.htcfg;
>>
>>        if (data_buf) {
>> -               tx_cfg = (struct mwifiex_ds_11n_tx_cfg *) data_buf;
>> +               tx_cfg = data_buf;
>>
>> I think pretty useless.  tx_cfg is a struct mwifiex_ds_11n_tx_cfg *.
> 
> True, but IMHO, this documents, particularly in a random snippet like
> this, what's going on. Arguably though, a better fix would be to move
> the cast to the place where this function is called.

Hi Julian,

Thanks for your comment. We will work on this.

Regards,
Bing