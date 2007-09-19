From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 23:27:09 +0100
Message-ID: <46F1A23D.8080606@gentoo.org>
References: <20070919181005.GB5483@tuxdriver.com>	<46F19DD0.2050605@gentoo.org> <20070919.151446.116351108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, kune@deine-taler.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tranquility.mcc.ac.uk ([130.88.200.145]:61019 "EHLO
	tranquility.mcc.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbXISW2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:28:46 -0400
In-Reply-To: <20070919.151446.116351108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Daniel Drake <dsd@gentoo.org>
> Date: Wed, 19 Sep 2007 23:08:16 +0100
> 
>> John, thanks a lot for your efforts, I hope you don't mind waiting one 
>> extra release cycle for me to sort a few things out.
> 
> Having "a driver" is always better for users than having "no driver".
> Please I ask you not to block this merge even if you think it is too
> early.

I don't understand your point. We already have this driver in mainline 
Linux.

zd1211rw-mac80211 does not currently add anything to the user experience 
over the existing driver, other than automatic rate adaption which is 
nice but hasn't proven itself to be of much importance given that the 
existing driver has lots of happy users and has never done it.

Also, this merge has been proposed in a form other than what me and 
Ulrich were envisioning (at least from earlier discussions). We want to 
convert drivers/net/wireless/zd1211rw to mac80211 directly. This would 
also avoid a rename and I think would save some hassle.

Sorry to be a pain, but I really would like some more time to catch up 
and make some last changes. I haven't yet even looked at Johannes' 
minimal filter flags implementation in the driver or Michael's fix.

Would you agree to let this wait until 2.6.25? You can hold me to that, 
although Ulrich should also comment on if he thinks he'd be ready by then.

Thanks and apologies,
Daniel
