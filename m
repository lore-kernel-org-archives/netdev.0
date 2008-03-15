From: Phil Oester <kernel@linuxace.com>
Subject: Re: [2.6.24.3][net] bug: TCP 3rd handshake abnormal timeouts
Date: Sat, 15 Mar 2008 08:27:29 -0700
Message-ID: <20080315152729.GA31048@linuxace.com>
References: <47DB28E9.4050309@oxeva.fr> <20080315065739.GL8953@1wt.eu> <20080315065849.GA11817@1wt.eu> <47DB8E17.8080309@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:59332
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751831AbYCOP1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2008 11:27:30 -0400
Content-Disposition: inline
In-Reply-To: <47DB8E17.8080309@oxeva.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 15, 2008 at 09:51:35AM +0100, Gabriel Barazer wrote:
> >Also, you say you have netfilter with conntrack. Is this on the client ?
> >If so, you should try disabling it to rule out any possible bug in the
> >connection tracking.
> 
> I have the conntrack  on both the client and server

Try doing

	echo 255 > /proc/sys/net/netfilter/nf_conntrack_log_invalid

and see if anything shows up in syslog when the problem appears.

Phil
