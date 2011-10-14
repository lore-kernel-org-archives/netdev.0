From: Marc Ballarin <ballarin.marc@gmx.de>
Subject: Re: [PATCH] r8169: fix driver shutdown WoL regression.
Date: Fri, 14 Oct 2011 14:12:21 +0200
Message-ID: <20111014141221.5736721ec0dc65de0537ac48@gmx.de>
References: <20111014105745.GA11204@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:38487 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752007Ab1JNMM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 08:12:26 -0400
In-Reply-To: <20111014105745.GA11204@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Oct 2011 12:57:45 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> ...
>   Marc, can you add your Tested-by: to this patch ? It avoids the extra
>   phy writes which were included in the previous revision of the patch.
>   They did not happen before the regression so there is no reason to
>   sneak them in -release. Works ok with RTL_GIGA_MAC_VER_34.

Works fine on RTL_GIGA_MAC_VER_33 as well.

Tested-by: Marc Ballarin <ballarin.marc@gmx.de>
