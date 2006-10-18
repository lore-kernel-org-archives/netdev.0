From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: Readd dropped assignment
Date: Wed, 18 Oct 2006 16:10:21 -0500
Message-ID: <4536983D.40603@lwfinger.net>
References: <20061017231212.A73D77B40A0@zog.reactivated.net> <200610181640.01140.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Daniel Drake <dsd@gentoo.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:23508 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751514AbWJRVKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 17:10:38 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610181640.01140.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Wednesday 18 October 2006 01:12, Daniel Drake wrote:
>> Larry Finger pointed out a problem with my ieee80211 IV/ICV stripping patch,
>> which I forgot about. Sorry about that.
>>
>> The patch readds the frame_ctl assignment which was accidently dropped.
>>
>> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> 
> Whoops. Please merge this as fast as possible, John.
> That's a real bug which prevents RX from working.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

> 
>> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
>> ===================================================================
>> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
>> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
>> @@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
>>  		break;
>>  	}
>>  
>> +	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
>>  	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
>>  	case IEEE80211_FTYPE_MGMT:
>>  		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
>>
> 

