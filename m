From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] diag: fix netlink API attributes
Date: Fri, 29 Nov 2013 08:42:25 +0000
Message-ID: <20131129084225.GC4100@casper.infradead.org>
References: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com>
 <20131128163816.GA32047@casper.infradead.org>
 <52977F44.6070002@6wind.com>
 <20131128221916.GB4100@casper.infradead.org>
 <5298503C.6080100@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Samuel.gauthier@6wind.com" <Samuel.gauthier@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56924 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab3K2Im2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 03:42:28 -0500
Content-Disposition: inline
In-Reply-To: <5298503C.6080100@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/13 at 09:28am, Nicolas Dichtel wrote:
> I think the following patch is also needed (not based on HEAD):
> 
> From 8aa4397d43fbd34deea9ed11677c04b460895f15 Mon Sep 17 00:00:00 2001
> From: Samuel Gauthier <samuel.gauthier@6wind.com>
> Date: Fri, 29 Nov 2013 09:15:34 +0100
> Subject: [PATCH] attr: Allow attribute type 0 parsing
> 
> The commit 6a8d90f5fec4 "attr: Allow attribute type 0" intended to
> allow the parsing of {netlink,packet,unix}_diag, even if they are
> using type 0 for valid attributes.
> 
> It lacked this part in nla_parse.
> 
> Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>

Good catch, applied, thanks!
