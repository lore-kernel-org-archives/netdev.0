From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix build system and configure script to use for cross
 build. Optional IPv6.
Date: Fri, 10 Dec 2010 08:14:52 -0800
Message-ID: <20101210081452.360e2689@nehalam>
References: <1291995271-9912-1-git-send-email-serj.kalichev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Serj Kalichev <serj.kalichev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49218 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755950Ab0LJQO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 11:14:58 -0500
In-Reply-To: <1291995271-9912-1-git-send-email-serj.kalichev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Dec 2010 18:34:31 +0300
Serj Kalichev <serj.kalichev@gmail.com> wrote:

> The Makefiles and configure script understand the external variables like
> CC, CFLAGS, LDFLAGS etc. So it can be used for cross build easily. The
> configure script use CC instead hardcoded gcc and search for the xtables
> within specified SYSROOT but not on the host. Two checks were added. The
> check for the IPv6 support and check for the Berkeley DB availability.
> The iproute2 can be build without IPv6 now.
> 
> Signed-off-by: Serj Kalichev <serj.kalichev@gmail.com>

IPv6 support should not be optional.


-- 
