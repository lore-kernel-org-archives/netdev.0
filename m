From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 11:09:32 -0400
Message-ID: <1148396972.21012.2.camel@localhost.localdomain>
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
Received: from ms-smtp-04.nyroc.rr.com ([24.24.2.58]:51852 "EHLO
	ms-smtp-04.nyroc.rr.com") by vger.kernel.org with ESMTP
	id S1751335AbWEWPJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 11:09:40 -0400
To: Simon Oosthoek <simon.oosthoek@ti-wmc.nl>
In-Reply-To: <44732162.6080107@ti-wmc.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-23 at 16:51 +0200, Simon Oosthoek wrote:

> > Use of /proc for an API is no longer desirable. Please rewrite.
> > -
> 
> hmm, ok, I'm not sure this will happen anytime soon (being a rather low 
> priority thing, which is also the reason it's not submitted as patch to 
> the kernel and not signed off), but what is currently the desirable method?
> 

 sysfs is the new interface into the kernel.  /proc is for processes
only (besides the old stuff).

Read up on:
 Documentation/filesystems/sysfs.txt and Documentation/kobject.txt

-- Steve


