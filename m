From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix build system and configure script to use for cross
 build. Optional IPv6.
Date: Fri, 10 Dec 2010 10:55:31 -0800
Message-ID: <20101210105531.47e9884a@nehalam>
References: <1291995271-9912-1-git-send-email-serj.kalichev@gmail.com>
	<20101210081452.360e2689@nehalam>
	<AANLkTikFHoMWybK8LWoSKzPhWjVEk1TUSypVsNxEq7nd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pkun <serj.kalichev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33421 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613Ab0LJSzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 13:55:43 -0500
In-Reply-To: <AANLkTikFHoMWybK8LWoSKzPhWjVEk1TUSypVsNxEq7nd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Dec 2010 21:13:28 +0300
Pkun <serj.kalichev@gmail.com> wrote:

> 2010/12/10 Stephen Hemminger <shemminger@linux-foundation.org>:
> > On Fri, 10 Dec 2010 18:34:31 +0300
> > Serj Kalichev <serj.kalichev@gmail.com> wrote:
> >
> >> The Makefiles and configure script understand the external variables like
> >> CC, CFLAGS, LDFLAGS etc. So it can be used for cross build easily. The
> >> configure script use CC instead hardcoded gcc and search for the xtables
> >> within specified SYSROOT but not on the host. Two checks were added. The
> >> check for the IPv6 support and check for the Berkeley DB availability.
> >> The iproute2 can be build without IPv6 now.
> >>
> >> Signed-off-by: Serj Kalichev <serj.kalichev@gmail.com>
> >
> > IPv6 support should not be optional.
> >
> >
> > --
> >
> 
> Why? I don't need an IPv6. Who need it - will switch it on. No problem
> 

Because I want iproute to be a complete tool, not a user configurable
nightmare. Just look at busybox to see what over configuration is.
