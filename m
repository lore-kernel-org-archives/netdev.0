From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: [PATCH -next v1] wireless: ath9k-htc: only load firmware in need
Date: Mon, 10 Sep 2012 15:53:27 +0530
Message-ID: <CAD2nsn284v68zNqxFQNBSh1ZMVF85ge=cGVmC1bgs2yu_zYQQg@mail.gmail.com>
References: <1345536267-9449-1-git-send-email-ming.lei@canonical.com>
	<CACVXFVPX1NB5uJ6yXkNbDWoX4OVdYfRU_=tsWC529-tH+3WfDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	ath9k-devel@lists.ath9k.org,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:56691 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab2IJKX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 06:23:28 -0400
In-Reply-To: <CACVXFVPX1NB5uJ6yXkNbDWoX4OVdYfRU_=tsWC529-tH+3WfDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Sep 1, 2012 at 10:41 AM, Ming Lei <ming.lei@canonical.com> wrote:
> On Tue, Aug 21, 2012 at 4:04 PM, Ming Lei <ming.lei@canonical.com> wrote:
>> It is not necessary to hold the firmware memory during the whole
>> driver lifetime, and obviously it does waste memory. Suppose there
>> are 4 ath9k-htc usb dongles working, kernel has to consume about
>> 4*50KBytes RAM to cache firmware for all dongles. After applying the
>> patch, kernel only caches one single firmware image in RAM for
>> all ath9k-htc devices just during system suspend/resume cycle.
>>
>> When system is ready for loading firmware, ath9k-htc can request
>> the loading from usersapce. During system resume, ath9k-htc still
>> can load the firmware which was cached in kernel memory before
>> system suspend.
>>
>> Cc: ath9k-devel@lists.ath9k.org
>> Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
>> Cc: Jouni Malinen <jouni@qca.qualcomm.com>
>> Cc: Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>
>> Cc: Senthil Balasubramanian <senthilb@qca.qualcomm.com>
>> Cc: "John W. Linville" <linville@tuxdriver.com>
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> ---
>> v1:
>>         fix double free of firmware in failue path of
>>         ath9k_hif_usb_firmware_cb
>
> Gentle ping, :-)

this patch is now in wireless-testing :-)

>
>
> Thanks,
> --
> Ming Lei
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
thanks,
shafi
