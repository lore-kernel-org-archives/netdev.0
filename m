From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Sat, 09 Sep 2006 11:04:59 -0500
Message-ID: <4502E62B.5060601@lwfinger.net>
References: <45021D4A.6040805@lwfinger.net> <20060909152305.GA27080@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>,
	Stefano Brivio <st3@riseup.net>,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:51935 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964788AbWIIQFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 12:05:23 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060909152305.GA27080@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Fri, Sep 08, 2006 at 08:47:54PM -0500, Larry Finger wrote:
> 
>> PLease send this upstream for inclusion in 2.6.18, if possible. This patch 
>> will not work for
>> wireless-2.6. That patch will be sent to you soon.
> 
> Are you saying this will break the upstream branch of wireless-2.6?
> I'm not too excited about that.  Under the normal process, that would
> mean 2.6.19 would be broken until we get the next patch.
> 
> When will the patch for the upstream branch be available?  Can you make
> that patch based on this one (i.e. apply this one before generating
> the next patch)?

It will not break wireless-2.6. I sent the equivalent of this patch for wireless-2.6 to you under 
the subject "[PATCH] bcm43xx-softmac: Init, shutdown and restart fixes" on August 21, just after I 
took over maintenance of bcm43xx-softmac. If this is not currently queued, please let me know. There 
is still a problem with one section of the code touched by that patch that is related to a 
synchronize_net() call. Michael and I are trying to get a network guru to answer some questions 
regarding that function. So far no response to our pleas.

I would like to get a listing of patches for bcm43xx-softmac that are queued but not yet applied, 
and the order in which they will be applied. I want to make sure nothing has fallen through the 
cracks, and that the patches will apply cleanly.

Thanks,

Larry
