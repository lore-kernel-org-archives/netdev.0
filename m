From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [BUG] problem with 3c905 on AMD64
Date: Wed, 13 Aug 2008 16:45:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808131642000.4551@wrl-59.cs.helsinki.fi>
References: <20080813005103.c7348e24.ian_bruce@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: ian_bruce@fastmail.fm
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55521 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbYHMNpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 09:45:38 -0400
In-Reply-To: <20080813005103.c7348e24.ian_bruce@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Aug 2008, ian_bruce@fastmail.fm wrote:

> Hardware: i386 and amd64 boxes, both with 3c905 network cards, directly
> connected with crossover ethernet cable.
> 
> Software: Linux 2.6.25/i686 and Linux 2.6.25/amd64, respectively, both
> from Debian packages.

In which stable .y version it's based on (in 2.6.25.7 some TCP related 
bugs got fixed)?

> While copying files from the i386 to the amd64, I found that the
> transfer rate was only 7Kbyte/s. This was the case with both FTP and
> HTTP, so it didn't seem like a user-level problem.
> 
> Strangely, when I tried copying files not FROM the i386, but only
> THROUGH it, as a router, the problem went away, and I got the much
> higher transfer rate I would have expected from the upstream link on the
> other side of the i386.
> 
> With a different network adapter (Atheros) in the amd64, the problem
> went away entirely.
> 
> The results were the same with the amd64 running Linux 2.6.18, so it's
> not an issue that's specific to a particular kernel version.
>
> I conclude: since the problem was fixed by using a different network
> adapter, with the same software configuration on both ends of the
> connection, this is a kernel issue. However, since it only manifests
> itself when the i386 is a connection endpoint, but not a router in the
> network path, it's a problem with the IP network stack, rather than the
> 3c905 hardware driver itself. The IP stack must somehow interact
> differently with this driver than with the one which did work.

Please make sure that the kernel is at least 2.6.25.7 or 2.6.26 based. 
Alternatively (if the kernel is older than that) you could try setting 
tcp_frto sysctl to 0 and see if that solves the problem.

-- 
 i.
