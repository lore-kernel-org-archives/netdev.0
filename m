From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7770] New: Network connection randomly drops
Date: Thu, 4 Jan 2007 09:25:02 -0800
Message-ID: <20070104092502.279e1a5c.akpm@osdl.org>
References: <200701041649.l04GnnjW021531@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, prusnik@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39201 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbXADRmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 12:42:44 -0500
To: netdev@vger.kernel.org
In-Reply-To: <200701041649.l04GnnjW021531@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Jan 2007 08:49:49 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7770
> 
>            Summary: Network connection randomly drops
>     Kernel Version: 2.6.19 onward
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: prusnik@gmail.com
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.19-rc4
> Distribution: ubuntu 6.10, 64 bit
> Hardware Environment: ASUS M2N-E (MCP55), AMD X2 4200+
> Software Environment: normal linux distro with a custom kernel
> Problem Description:
> It started when I compiled the stable 2.6.19 kernel (first after rc4). The
> network connection to the router just dropped and I can find no reason why it is
> so. I have to revive the connection via /etc/init.d/networking restart command
> and the connection is there again. At first I was doing remote connection
> (tsclient in ubuntu) on another ubuntu dapper machine. The connection would
> randomly terminate. I assumed it was the program, but then I did a further test.
> I used mc (midnight commander) to copy some large files (a couple ubuntu iso-s)
>  to this machine (which acts as a file server) via NFS (and via router) and
> back. The connection would drop! The event is more frequent if I transfer the
> files from that computer than vice versa.
> I then rerun linux with 2.6.19-rc4 kernel and transfers were stable without a
> single connection drop. I then assumed it should be the newer forcedeth driver
> to blame but apparently it isn't. I put the 0.57 driver into the 2.6.20-rc3 and
> the problem persists. I even tried this patch from the bug #7684 but this didn't
> help either.
> 
> Steps to reproduce:
> Hopefully with this hardware I mentioned, plain ubuntu 6.10 64 bit installation
> with a kernel higher than 2.6.19-rc4. Config and other status files are in the
> attachment.
> 
