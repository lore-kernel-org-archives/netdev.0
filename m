From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress
 qdisc
Date: Wed, 08 Apr 2015 23:14:56 -0400 (EDT)
Message-ID: <20150408.231456.1063648455572594170.davem@davemloft.net>
References: <1428535575-7736-2-git-send-email-ast@plumgrid.com>
	<20150408.224404.1913719826015357860.davem@davemloft.net>
	<5525EC69.1080606@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbbDIDO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 23:14:58 -0400
In-Reply-To: <5525EC69.1080606@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 08 Apr 2015 20:05:13 -0700

> I'm sure there is a way to propagate the offset into the programs.
> It's not about efficiency of programs, but about consistency.
> Programs should know nothing about kernel. Sending network offset
> into them is exposing this very specific kernel behavior.

It can be performed by the data access helpers the JIT'd programs
have to invoke anyways.
