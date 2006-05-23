From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 16:20:01 +0100
Message-ID: <1148397601.25255.83.camel@localhost.localdomain>
References: <44731733.7000204@ti-wmc.nl>
	 <20060523073851.39c3b5fe@localhost.localdomain>
	 <44732162.6080107@ti-wmc.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herman Elfrink <herman.elfrink@ti-wmc.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:63875 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1750753AbWEWPGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 11:06:19 -0400
To: Simon Oosthoek <simon.oosthoek@ti-wmc.nl>
In-Reply-To: <44732162.6080107@ti-wmc.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Maw, 2006-05-23 at 16:51 +0200, Simon Oosthoek wrote:
> > Use of /proc for an API is no longer desirable. Please rewrite.
> > -
> 
> hmm, ok, I'm not sure this will happen anytime soon (being a rather low 
> priority thing, which is also the reason it's not submitted as patch to 
> the kernel and not signed off), but what is currently the desirable method?

sysfs will let you provide the same information in a much more
structured manner, and it will do most of the hard work for you as well.

