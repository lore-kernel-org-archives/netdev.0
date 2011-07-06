From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 6 Jul 2011 17:58:29 -0400
Message-ID: <20110706215829.GC17652@canuck.infradead.org>
References: <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630084933.GA24074@canuck.infradead.org>
 <4E0C8368.5090502@hp.com>
 <20110704135019.GA801@canuck.infradead.org>
 <4E146652.7010205@hp.com>
 <20110706141808.GA17652@canuck.infradead.org>
 <4E1471DC.2090407@hp.com>
 <20110706154900.GB17652@canuck.infradead.org>
 <4E148C16.8090505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59242 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1GFV6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 17:58:33 -0400
Content-Disposition: inline
In-Reply-To: <4E148C16.8090505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2011 at 12:23:50PM -0400, Vladislav Yasevich wrote:
> You are right.  Without a receiver patch, a linux receiver would stay in 0-window condition
> while sending a SHUTDOWN with a_rwnd of 0.
> 
> How about instead of checking for "Not greater then or equals", we instead simply test for
> "less then"?

Agreed

Will repost the patch with your suggestions included and look into the
receiver patch as well.
