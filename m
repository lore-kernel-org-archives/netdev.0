From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [ovs-dev] [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 10:32:36 -0500
Message-ID: <1322494356.7338.75.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	 <1322050976.2039.125.camel@mojatatu>
	 <20111128130409.GB16828@gondor.apana.org.au>
	 <1322488954.7338.66.camel@mojatatu>  <4ED3A85A.1030003@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, dev@openvswitch.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Martin Casado <casado@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41059 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab1K1Pcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 10:32:42 -0500
Received: by yenl6 with SMTP id l6so2966810yen.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 07:32:42 -0800 (PST)
In-Reply-To: <4ED3A85A.1030003@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 07:27 -0800, Martin Casado wrote:

> This is a common misunderstanding about OpenFlow.  It does not require 
> the first packet of each flow to go to the controller.  

I am reading this to mean that the switch CPU will resolve things?
Typically those tend to be tiny cpus.

> In fact, no 
> production system I'm aware of does this.  Generally OpenFlow-based 
> solutions targeted at large environments (e.g. data center, or WAN)  
> send only traditional control traffic to the controller (e.g. BGP or 
> OSPF), or none at all.

Even OSPF or BGP  would be problematic imo if the architecture doesnt
allow prioritization of some form towards the controller.

cheers,
jamal
