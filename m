From: David Miller <davem@davemloft.net>
Subject: Re: Just "[PATCH]..." -- Re: [PATCH 1/5] rndis_host: support
 ETHTOOL_GPERMADDR
Date: Tue, 06 Oct 2009 15:01:58 -0700 (PDT)
Message-ID: <20091006.150158.114563123.davem@davemloft.net>
References: <1254863142-14698-1-git-send-email-linville@tuxdriver.com>
	<20091006213924.GE2911@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933064AbZJFWCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:02:04 -0400
In-Reply-To: <20091006213924.GE2911@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 6 Oct 2009 17:39:25 -0400

> On Tue, Oct 06, 2009 at 05:05:42PM -0400, John W. Linville wrote:
>> Signed-off-by: John W. Linville <linville@tuxdriver.com>
>> ---
>>  drivers/net/usb/rndis_host.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
>> index d032bba..0caa800 100644
>> --- a/drivers/net/usb/rndis_host.c
>> +++ b/drivers/net/usb/rndis_host.c
>> @@ -418,6 +418,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
>>  		goto halt_fail_and_release;
>>  	}
>>  	memcpy(net->dev_addr, bp, ETH_ALEN);
>> +	memcpy(net->perm_addr, bp, ETH_ALEN);
>>  
>>  	/* set a nonzero filter to enable data transfers */
>>  	memset(u.set, 0, sizeof *u.set);
> 
> Ooops...ignore the "1/5" part -- this is the only one...

Ok :-)
