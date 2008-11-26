From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Host<->guest channel interface advice needed
Date: Wed, 26 Nov 2008 16:07:01 +0300
Message-ID: <20081126130701.GB8921@ioremap.net>
References: <20081126123919.GC3521@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gleb Natapov <gleb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:34149 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbYKZNHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 08:07:03 -0500
Content-Disposition: inline
In-Reply-To: <20081126123919.GC3521@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gleb.

On Wed, Nov 26, 2008 at 02:39:19PM +0200, Gleb Natapov (gleb@redhat.com) wrote:
> The interfaces that are being considered are netlink socket (only datagram
> semantics, linux specific), new socket family or character device with
> different minor number for each channel. Which one better suits for
> the purpose?  Is there other kind of interface to consider? New socket
> family looks like a good choice, but it would be nice to hear other
> opinions before starting to work on it.

What about X (or whatever else) protocol running over host-guest network
device, which are in the kernel already?

-- 
	Evgeniy Polyakov
