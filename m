From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Debugging kernel lockups during network activity
Date: Thu, 27 Jul 2006 11:27:44 -0700
Message-ID: <20060727112744.7e6ed383@localhost.localdomain>
References: <20060727181943.GD23091@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48042 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750935AbWG0S1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 14:27:52 -0400
To: "Art Haas" <ahaas@airmail.net>
In-Reply-To: <20060727181943.GD23091@artsapartment.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jul 2006 13:19:43 -0500
"Art Haas" <ahaas@airmail.net> wrote:

> Hi.
> 
> I've got Fedora Rawhide running on a SMP PIII machine, and the latest
> kernels from Fedora have been locking up when I run 'yum update' to
> get the latest packages. I also experience lock-ups when I use
> Firefox to do some web browsing. Not all my network usage results in a
> lockup, however. I can usually do 'git pull' and update git itself or
> my copy of Linus' kernel tree without problems, as well as update my
> GCC repo with subversion and Mozilla with cvs. I realize that running
> Fedora Rawhide means when things break I can keep the pieces, so
> the lockups or other occasional issues are not unexpected.
> 
> I'm writing to the 'netdev' list in an effort to get some pointers as to
> how I can try and debug the problem. When I boot off my FC5 install
> disk and run 'linux rescue' I can chroot to the system and update
> the machine without problems, and I've also run memtest86 on it and
> found no memory issues, so I'm certain the problem is in the Fedora
> kernel. I don't know how to try and narrow down the problem to provide a
> decent bug report, or if there is/are settings I can adjust which may
> help to identify what is happening.
> 
> I'd mailed the fedora-test list and received no response, so I thought I
> could try the main network development list. Are there a few tips,
> tricks, or pointers that could be sent my way which others use to debug
> networking problems like the one described above? Thanks in advance, and
> my thanks to everyone working on the kernel.
> 
> Art Haas

Basic kernel debugging is good place to start.  If you can place a serial
console on the machine, and run commands from there. If that isn't possible
make sure and run from console virtual terminal (ie not X) so that if
there are kernel messages you can see them.  The debugging sysrq-p and
sysrq-t will show current state if machine isn't completely dead.

