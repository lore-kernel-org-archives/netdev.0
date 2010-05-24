From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Mon, 24 May 2010 15:42:11 +1000
Message-ID: <20100524054211.GA26271@gondor.apana.org.au>
References: <20100520172918.GA17613@shamino.rdu.redhat.com> <20100520231630.GA22593@gondor.apana.org.au> <20100521003939.GA2223@localhost.localdomain> <20100520.224944.102694876.davem@davemloft.net> <20100521105128.GA29521@hmsreliant.think-freely.org> <20100521110847.GA29878@gondor.apana.org.au> <20100521164054.GB29521@hmsreliant.think-freely.org> <20100522014957.GA8779@gondor.apana.org.au> <20100522122632.GA2075@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:53138 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751430Ab0EXFmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 01:42:33 -0400
Content-Disposition: inline
In-Reply-To: <20100522122632.GA2075@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 22, 2010 at 08:26:32AM -0400, Neil Horman wrote:
>
> first place.  When we register the cgroup subsystem, we don't register an attach
> method, so we never get a chance to assign task_cls_sate(tsk)->classid to any
> non-zero value.  I've got a version of the patch that add that, but for some

No I don't think you need an attach method.

The task_struct has a pointer to the cgroups, which in turn has
a pointer to the cgroup_subsys_state that we allocated in the
cls_cgroup module.

Did you try building cls_cgroup into the kernel?

Perhaps there is a bug in how we register it at run-time, or
perhaps the cgroups infrastructure itself is buggy.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
