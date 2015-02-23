From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next v3 2/2] multicast: Extend ip address command to
 enable multicast group join/leave on IP level.
Date: Mon, 23 Feb 2015 09:45:24 +0100
Message-ID: <20150223084524.GA1116@haze>
References: <1424672814-2998-1-git-send-email-challa@noironetworks.com>
 <1424672814-2998-3-git-send-email-challa@noironetworks.com>
 <54EADA49.6020308@miraclelinux.com>
 <CAN_zqfP0do+haTBOTecjNqBAdqEdj2JBam=_XiXsRnrASHMV3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	<davem@davemloft.net>
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:57918 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbBWIsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 03:48:05 -0500
Content-Disposition: inline
In-Reply-To: <CAN_zqfP0do+haTBOTecjNqBAdqEdj2JBam=_XiXsRnrASHMV3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2015 at 11:55:15PM -0800, Madhu Challa wrote:
> Good point. It should never happen because the "ip command" would not
> allow autojoin with a non multicast address. However in v1 of the
> patch I was doing this via a workqueue and could not return an error.
> Its not a problem anymore since ip_mc_config can return an error. I
> will remove it. I will wait till tomorrow to see if there are any
> other comments.
>

I was about to send in a patchset that adds UDP bearer support for TIPC, 
after rebasing it on top of this i could remove all deferred setup work
for mcast.
Thanks!

//E
