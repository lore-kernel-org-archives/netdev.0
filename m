From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 10:07:29 -0400
Message-ID: <1206713249.4429.69.camel@localhost>
References: <47EC399E.90804@sun.com>
	 <20080327.173418.18777696.davem@davemloft.net>
	 <20080328012234.GA20465@gondor.apana.org.au>
	 <20080327.183844.74572930.davem@davemloft.net>
	 <20080328102931.GA23039@gondor.apana.org.au>
	 <20080328105629.GG1011@elte.hu>
	 <20080328110621.GA23342@gondor.apana.org.au>
	 <20080328112928.GA23547@gondor.apana.org.au>
	 <1206706759.4429.58.camel@localhost>
	 <20080328132643.GA24180@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:10890 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbYC1OIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:08:18 -0400
Received: by el-out-1112.google.com with SMTP id v27so92833ele.17
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 07:08:18 -0700 (PDT)
In-Reply-To: <20080328132643.GA24180@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-28-03 at 21:26 +0800, Herbert Xu wrote:
> I agree that using jiffies is a pretty coarse approximation of
> proper scheduling.  However, in the absence of a better solution
> we have to live with it.

I know it works well enough and has for years; sure you could do better
but i wasnt questioning the solution - more than anything on my part
that was curiosity.

> Perhaps running these out of process context is the correct
> approach.

I saw something from Max Krasnyansky along those lines but havent quiet
followed it up. Should be interesting to see the effect over a large
types of workloads.

cheers,
jamal

