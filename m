From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
	IPoIB
Date: Thu, 23 Aug 2007 18:25:03 -0400
Message-ID: <1187907903.4279.28.camel@localhost>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	 <20070821.212229.82050253.davem@davemloft.net> <46CC6DD1.5020105@hp.com>
	 <20070822.132145.90824527.davem@davemloft.net>
	 <1187906650.4279.16.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:56934 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762345AbXHWWZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 18:25:08 -0400
Received: by rv-out-0910.google.com with SMTP id k20so501690rvb
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 15:25:07 -0700 (PDT)
In-Reply-To: <1187906650.4279.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-23-08 at 18:04 -0400, jamal wrote:

> The litmus test is the same as any change that is supposed to improve
> net performance - it has to demonstrate it is not intrusive and that it
> improves (consistently) performance. The standard metrics are
> {throughput, cpu-utilization, latency} i.e as long as one improves and
> others remain zero, it would make sense. Yes, i am religious for
> batching after all the invested sweat (and i continue to work on it
> hoping to demystify) - the theory makes a lot of sense.

Before someone jumps and strangles me ;-> By "litmus test" i meant as
applied to batching. [TSO already passed - iirc, it has been
demostranted to really not add much to throughput (cant improve much
over closeness to wire speed) but improve CPU utilization].

cheers,
jamal


