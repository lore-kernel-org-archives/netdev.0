From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] dlm: avoid using sctp_do_peeloff directly
Date: Fri, 10 Jul 2015 06:25:50 -0400
Message-ID: <20150710102550.GB21910@hmsreliant.think-freely.org>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
 <a5b66c7f050a17cd2b8f0f4d6bbb3a5837d593f5.1434645734.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47030 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbbGJKZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 06:25:54 -0400
Content-Disposition: inline
In-Reply-To: <a5b66c7f050a17cd2b8f0f4d6bbb3a5837d593f5.1434645734.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 09, 2015 at 11:15:20AM -0300, Marcelo Ricardo Leitner wrote:
> This patch reverts 2f2d76cc3e93 ("dlm: Do not allocate a fd for
> peeloff") but also takes benefit on an updated sockopt
> SCTP_SOCKOPT_PEELOFF, which now avoids allocating file descriptors for
> kernel users.
> 
> By this we avoid creating a direct dependency from dlm to sctp module,
> which can then be left unloaded if dlm is not really using it.
> 
> Note that this was preferred other than a module split as it once was
> split and was merged back in 2007 by commit 6ed7257b4670 ("[DLM]
> Consolidate transport protocols") so that we don't revert it.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Acked-by: Neil Horman <nhorman@tuxdriver.com>
