From: Jonathan Thibault <jonathan@navigue.com>
Subject: Re: large divisor for flow classifier
Date: Fri, 15 Oct 2010 19:58:18 -0400
Message-ID: <4CB8EA9A.9020604@navigue.com>
References: <4CB899F7.0@navigue.com> <1287172905.2799.8.camel@edumazet-laptop> <4CB8C341.40000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:36640 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab0JOX6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 19:58:42 -0400
In-Reply-To: <4CB8C341.40000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will certainly look into that.

Jonathan

On 15/10/10 05:10 PM, Jarek Poplawski wrote:
> Eric Dumazet wrote:
> 
> Because of low SFQ_DEPTH, which limits its queue to 127 packets,
> SFQ isn't suitable for serving so many users. There is sch_drr as
> a replacement, alas more complex and undocumented, but google should
> help you enough.
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=13d2a1d2b032de08d7dcab6a1edcd47802681f96
> 
> Jarek P.

