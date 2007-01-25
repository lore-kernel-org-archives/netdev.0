From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought
 up
Date: Thu, 25 Jan 2007 10:30:39 +0100
Message-ID: <20070125103039.325dd757@griffin.suse.cz>
References: <1169707854.10593.41.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:34173 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965732AbXAYJan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 04:30:43 -0500
In-Reply-To: <1169707854.10593.41.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Jan 2007 01:50:54 -0500, Pavel Roskin wrote:
> It turns out d80211 uses the "config" method of the hardware drivers
> very sparingly.  It's only used for scanning and in ioctl commands.  It
> is not called after the interface has been brought up with the "open"
> method.
> 
> I don't know whose responsibility it should be to apply the
> configuration when the interface is brought up.  I'm not familiar with
> d80211 design principles.

I think it should be done in the stack (actually, it's on todo list for
quite some time). However, I don't consider this as a big problem -
just do it in a driver (like your patch does) for now.

 Jiri

-- 
Jiri Benc
SUSE Labs
