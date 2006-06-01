From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Thu, 1 Jun 2006 00:46:08 -0600
Message-ID: <20060601004608.C21730@openss7.org>
References: <20060531090301.GA26782@2ka.mipt.ru> <20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru> <20060531.114127.14356069.davem@davemloft.net> <20060601060424.GA28087@2ka.mipt.ru> <20060601001825.A21730@openss7.org> <20060601063012.GC28087@2ka.mipt.ru>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:38035 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S1750709AbWFAGqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 02:46:10 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060601063012.GC28087@2ka.mipt.ru>; from johnpol@2ka.mipt.ru on Thu, Jun 01, 2006 at 10:30:13AM +0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

On Thu, 01 Jun 2006, Evgeniy Polyakov wrote:
> 
> Since pseudo-randomness affects both folded and not folded hash
> distribution, it can not end up in different results.

Yes it would, so to rule out pseudo-random effects the pseudo-
random number generator must be removed.

> 
> You are right that having test with 2^48 values is really interesting,
> but it will take ages on my test machine :)

Try a usable subset; no pseudo-random number generator.
