From: Dave Jones <davej@redhat.com>
Subject: Re: odd RTL8139 quirk.
Date: Tue, 29 Apr 2008 18:28:04 -0400
Message-ID: <20080429222804.GE2859@redhat.com>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429221011.GD2859@redhat.com> <48179F02.6020309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095AbYD2W2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 18:28:12 -0400
Content-Disposition: inline
In-Reply-To: <48179F02.6020309@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 06:19:46PM -0400, Jeff Garzik wrote:
 > Dave Jones wrote:
 > >>From a quick eyeball, that would seem that it still requires a choice
 > > to be made whether or not to enable CONFIG_8139TOO_PIO
 > > What I had in mind was to make that whole USE_IO_OPS ifdef
 > > (and related bits) if (modparm==.. instead of #ifdefs.
 > 
 > 
 > The patch is the requisite groundwork to add such a module param... 
 > iomap support is required to enable runtime rather than compile-time 
 > MMIO/PIO switching.
 > 
 > e100 does this with the 'use_io' module param.

Ah, in which case, I endorse this proposal heartily :)

	Dave

-- 
http://www.codemonkey.org.uk
