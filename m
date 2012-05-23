From: Dan Williams <dcbw@redhat.com>
Subject: Re: Kernel doesn't propagate DNSSL to userspace (e.g.
 NetworkManager)
Date: Wed, 23 May 2012 09:24:25 -0500
Message-ID: <1337783065.25721.1.camel@dcbw.foobar.com>
References: <fb24ca84-9976-42ab-b81a-73955b753731@zmail19.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Williams <danwilli@redhat.com>,
	danw@gnome.org
To: Pavel Simerda <psimerda@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758329Ab2EWOXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 10:23:39 -0400
In-Reply-To: <fb24ca84-9976-42ab-b81a-73955b753731@zmail19.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 04:16 -0400, Pavel Simerda wrote:
> Hi,
> 
> I filed a bugreport to about lack of DNSSL support in kernel:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=824121
> 
> While NetworkManager recieves RDNSS neighbor discovery user option from kernel, it doesn't recieve DNSSL at all. This can be debugged with NetworkManager
> (or hopefully some better testing tool) and radvdump (to check if DNSSL is present).
> 
> radvdump reports DNSSL is there, NetworkManager gets no netlink message from kernel.
> 
> kernel-3.3.4-4.fc17.x86_64
> NetworkManager-0.9.4.0-7.git20120403.fc17.x86_64
> 
> Dave Jones asked me to contact this ML directly. I'm offlist.

So Pierre Ossman sent some RFC patches for DNSSL back in December 2010,
but Dave Miller wanted actual formal submissions which Pierre never got
around to doing.  I'll resubmit Pierre's second patch, which exports all
options the kernel doesn't care about to userspace.

Sun, 12 Dec 2010:
"[RFC][PATCH] Export all RA options that we don't handle to userspace"

Dan
