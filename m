From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch] [iproute] ip exit, ip and tc line number
Date: Wed, 3 Mar 2010 16:30:28 -0800
Message-ID: <20100303163028.21ef4194@nehalam>
References: <4B8D58D9.7050202@unipex.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michele Petrazzo - Unipex <michele.petrazzo@unipex.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36662 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab0CDAae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 19:30:34 -0500
In-Reply-To: <4B8D58D9.7050202@unipex.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Mar 2010 19:28:41 +0100
Michele Petrazzo - Unipex <michele.petrazzo@unipex.it> wrote:

> Hi,
> I create a small patch that solve an annoying problem that I found on 
> "ip -batch" usage, so the command exits without end the parsing of the 
> batch file also if I specify the -force switch.
> Also add the shown of the right line number where batch file fail for 
> both ip and tc
> 
> Michele

The line number stuff is wrong, but the real problem was that ip
was counting lineno rather than using cmdlineno which is done
by getcmdline(). I will fix that.

The force issue is a different problem so please split out that part
and resubmit.
