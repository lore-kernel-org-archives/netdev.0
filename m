From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 06 May 2009 16:31:42 -0700 (PDT)
Message-ID: <20090506.163142.112368323.davem@davemloft.net>
References: <1241586309-12112-5-git-send-email-dhananjay@netxen.com>
	<20090506.153714.122287244.davem@davemloft.net>
	<4A0217F6.7060005@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbZEFXbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:31:47 -0400
In-Reply-To: <4A0217F6.7060005@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed, 6 May 2009 16:06:30 -0700

> The reason for RSS was to distribute the ingress traffic
> to different CPUs. At 10Gbps, without RSS, one CPU was
> saturating, acting as bottleneck. I can do 1Gbps with
> only one CPU only 50% saturated, this to on a low end
> server.
> 
> The fallout is more msix vectors being consumed for RSS,
> when they don't really bring any performance gain.
> 
> Since NetXen has single driver, unlike others, it needs
> to be dealt based on NIC board type.

Thanks for ignoring my email.

I'll say it again, maybe you'll listen this time.

If a user has very cpu intensive netfilter or routing
rules installed, the RSS flow seperation to different
CPUs can help even at 1GB speeds.

Therefore, your change will introduce performance regressions.
