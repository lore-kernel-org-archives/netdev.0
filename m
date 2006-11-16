From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Max number of TCP sessions
Date: Thu, 16 Nov 2006 14:21:35 -0800
Message-ID: <20061116142135.49bf524e@freekitty>
References: <455CC8C9.2050509@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27863 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1424743AbWKPWVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 17:21:38 -0500
To: James Courtier-Dutton <James@superbug.co.uk>
In-Reply-To: <455CC8C9.2050509@superbug.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Nov 2006 20:23:37 +0000
James Courtier-Dutton <James@superbug.co.uk> wrote:

> Hi,
> 
> For a host using a Pentium 4 CPU at 2.8Mhz, what is a sensible max value 
> for number of TCP sessions this host could run under Linux?
> Bandwidth per TCP session is likely to be about 10kbytes/second.
> 

Look at your fundamental limits:

	* how fast is your network interface?
	* how fast is your bus?
	* how much kernel memory is available.


-- 
Stephen Hemminger <shemminger@osdl.org>
