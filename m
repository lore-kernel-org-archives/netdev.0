From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RFC] Disable addrconf on ~multicast interfaces?
Date: Thu, 5 Oct 2006 09:08:30 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0610050907160.22625@netcore.fi>
References: <20061005053531.GA19482@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:13957 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S1751001AbWJEGJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 02:09:07 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20061005053531.GA19482@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2006, Herbert Xu wrote:
> Are there any non-multicast interfaces that require addrconf?
> In other words, what does the following patch break :)

Point-to-point (or NOARP) interfaces such as tunnels.   I'm not sure 
what are the right flags to check..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
