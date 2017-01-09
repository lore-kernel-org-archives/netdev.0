From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [stable 4.4.y] ppp: defer netns reference release for ppp channel
Date: Mon, 9 Jan 2017 11:47:06 +0100
Message-ID: <20170109104706.f4nzzl44ve7dgwhm@alphalink.fr>
References: <75ccacc3-a4b4-21ac-aae4-2c8968215738@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:52976 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964922AbdAIKrJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:47:09 -0500
Content-Disposition: inline
In-Reply-To: <75ccacc3-a4b4-21ac-aae4-2c8968215738@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 09:12:15PM +0000, Simon Arlott wrote:
> Please apply the following patch to linux-stable 4.4.y:
> 
>   commit 205e1e255c479f3fd77446415706463b282f94e4
>   ppp: defer netns reference release for ppp channel
> 
> This is already present in 4.8.y and fixes an issue with ppp channels
> that would otherwise cause a BUG() in ppp_pernet while a global ppp
> mutex is held, preventing further ppp connections from being
> established.
> 
FYI, this is now fixed in linux-4.4.y (patch entered v4.4.40).

Regards,

Guillaume
