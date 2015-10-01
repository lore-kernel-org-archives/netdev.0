From: Yanko Kaneti <yaneti@declera.com>
Subject: Re: [regression] 6ae459bd skbuff: Fix skb checksum flag on skb pull
Date: Thu, 1 Oct 2015 13:51:29 +0300
Message-ID: <20151001105129.GA32446@declera.com>
References: <1443686148.2726.6.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443686148.2726.6.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu-10/01/15-2015 09:55, Mike Galbraith wrote:
..... 
> 
> Bisected and post bisect verified by applying/removing a revert.
> 
> Log:
> 
> 6ae459bdaaeebc632b16e54dcbabb490c6931d61 is the first bad commit
> commit 6ae459bdaaeebc632b16e54dcbabb490c6931d61
> Author: Pravin B Shelar <pshelar@nicira.com>
> Date:   Tue Sep 22 12:57:53 2015 -0700
> 
>     skbuff: Fix skb checksum flag on skb pull
....

I've also chased a regression in Rawhide down to this commit.
What happended here after and update from  rc2 and rc3 was that 
all connections to ::1 failed with timeout, while v4 connections to
127.0.0.1 worked as expected.

Bisected on mainline and verified a revert of this commit fixes it.

-
Yanko
