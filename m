From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH net-2.6/stable] tg3: Restrict phy ioctl access
Date: Wed, 16 Feb 2011 14:39:35 -0800
Message-ID: <20110216223935.GF22056@kroah.com>
References: <1297810270-4690-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, stable@kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:36118 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755158Ab1BPW5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Feb 2011 17:57:10 -0500
Content-Disposition: inline
In-Reply-To: <1297810270-4690-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 15, 2011 at 02:51:10PM -0800, Matt Carlson wrote:
> If management firmware is present and the device is down, the firmware
> will assume control of the phy.  If a phy access were allowed from the
> host, it will collide with firmware phy accesses, resulting in
> unpredictable behavior.  This patch fixes the problem by disallowing phy
> accesses during the problematic condition.
> 
> Upstream commit ID f746a3136a61ae535c5d0b49a9418fa21edc61b5

There is no such upstream git commit id in Linus's tree.  What am I
doing wrong here?

confused,

greg k-h
