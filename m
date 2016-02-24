From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 07/20] igb: add a character device to support AVB
Date: Wed, 24 Feb 2016 16:45:20 -0500 (EST)
Message-ID: <20160224.164520.2124246431953318783.davem@davemloft.net>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1456287984-10459-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMiHz+5n1iHO9s2Vuz_ssgJWTNBU-1gCgf_Bf0Rrc-kA-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, gangfeng.huang@ni.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbcBXVpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:45:22 -0500
In-Reply-To: <CAJ3xEMiHz+5n1iHO9s2Vuz_ssgJWTNBU-1gCgf_Bf0Rrc-kA-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Wed, 24 Feb 2016 22:06:25 +0200

> On Wed, Feb 24, 2016 at 6:26 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> From: Gangfeng Huang <gangfeng.huang@ni.com>
> 
>> This patch create a character device for Intel I210 Ethernet controller,
> 
> wait, do we want L2 network driver to create char devices
> 
>> it can be used for developing Audio/Video Bridging applications,Industrial
>> Ethernet applications which require precise timing control over frame
>> transmission, or test harnesses for measuring system latencies and sampling
>> events.
> 
> for various reasons such as the above?

This is definitely not the direction to go for such a facility.
Character devices make no sense at all, and are an invitation for
ad-hoc user interfaces for what should be a generic and clean
facility.

There is no reason we cannot provide this facility with extensions
of traditional networking APIs such as netlink or recvmsg/sendmsg
over a raw or AF_PACKET socket.

If there has been a lot of work, time and effort put into this
character device solution then that's too bad.  Because anything that
ends up being user facing should have been proposed here on netdev
from the start.

I'm not applying this, no way.
