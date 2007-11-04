From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Mon, 5 Nov 2007 00:01:03 +0100
Message-ID: <200711050001.03699.ak@suse.de>
References: <20071103.162337.83099185.davem@davemloft.net> <200711041326.38380.ak@suse.de> <20071104.135621.48992864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, acme@redhat.com,
	jarkao2@o2.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58453 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbXKDXBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 18:01:07 -0500
In-Reply-To: <20071104.135621.48992864.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 04 November 2007 22:56:21 David Miller wrote:
> From: Andi Kleen <ak@suse.de>

> This makes a huge different as we have to set NR_CPUS to 4096
> in order to handle the cpu numbering of some UltraSPARC-IV
> machines.

Really? Hopefully you have a large enough stack then. There 
are various users who put char str[NR_CPUS] on the stack
and a few other data structures also get incredibly big with
NR_CPUS arrays.

If it's for sparse cpu ids -- x86 handles those with an 
translation array.

-Andi
