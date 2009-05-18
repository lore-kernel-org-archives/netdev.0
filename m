From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 11:14:11 +0000
Message-ID: <20090518111411.GB11162@ff.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090516083158.GA3013@ami.dom.local> <298f5c050905180339k77006e21ka0955958489c41c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:40732 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbZERLOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 07:14:19 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1078575wah.21
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 04:14:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905180339k77006e21ka0955958489c41c7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 11:39:02AM +0100, Antonio Almeida wrote:
> Hi!
> 
> Here the information you asked:

Very nice, but there are some questions:
- if this analyser uses tcp we definitely need tso off as well during
  these tests,
- it would be nice to use two patches I've sent to exclude known (now)
  reasons.

With the above I expect accuracy should be better, but definitely not
like hfsc (plus no higher than 1000Mbit rate reported after stopping
effect).

Thanks,
Jarek P.

> 
> # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: off
> 
> # ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: off
> 
> The bridge is between eth0 and eth1
...
