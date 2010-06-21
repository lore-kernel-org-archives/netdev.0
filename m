From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 2.6.34 + IPv6: Oops?
Date: Mon, 21 Jun 2010 09:19:46 -0700
Message-ID: <20100621091946.63f26b21@nehalam>
References: <20100619175352.GA8482@EIS>
	<20100621153018.GA2433@EIS>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Klauer <Andreas.Klauer@metamorpher.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59157 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757288Ab0FUQTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 12:19:49 -0400
In-Reply-To: <20100621153018.GA2433@EIS>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jun 2010 17:30:18 +0200
Andreas Klauer <Andreas.Klauer@metamorpher.de> wrote:

> Hi,
> 
> no one replied so far - am I reporting this to the wrong place?
> Please advise.
> 
> I've done some more testing; I can reproduce the issue now on different 
> hardware (my desktop at home), with a clean environment (freshly boot- 
> strapped Debian Lenny). Which should make things more interesting. 
> 
> The issue seems to be compiler related. It occurs if the kernel is 
> compiled with Debian Lenny "gcc (Debian 4.3.2-1.1) 4.3.2". It does 
> not occur (or at least I can't reproduce it) if the kernel was 
> compiled with Gentoo "gcc (Gentoo 4.4.4 p1.0) 4.4.4".
> 
> Screenshot:
> http://www.metamorpher.de/kernel/panic2.jpg
> 
> Steps to reproduce:
> http://www.metamorpher.de/kernel/steps-to-reproduce.txt
> 
> kernel config and lspci also available here:
> http://www.metamorpher.de/kernel/
> 
> Regards
> Andreas Klauer
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Unfortunately, Greg seems to be slow in getting 2.6.34.1 out.
These patches are related:


http://marc.info/?l=linux-netdev&m=127472600330413
http://marc.info/?l=linux-netdev&m=127472599530407

-- 
