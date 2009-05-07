From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Thu, 7 May 2009 08:15:09 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0905070811150.3058@ask.diku.dk>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
 <1241586309-12112-5-git-send-email-dhananjay@netxen.com>
 <20090506.153714.122287244.davem@davemloft.net> <4A0217F6.7060005@netxen.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:43607 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbZEGGVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 02:21:43 -0400
In-Reply-To: <4A0217F6.7060005@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 May 2009, Dhananjay Phadke wrote:

> The reason for RSS was to distribute the ingress traffic
> to different CPUs. At 10Gbps, without RSS, one CPU was
> saturating, acting as bottleneck. I can do 1Gbps with
> only one CPU only 50% saturated, this to on a low end
> server.

1Gbit/s throughput tests with MTU size frames is a bad measurement target.
Packets Per Sec is the key factor.

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
