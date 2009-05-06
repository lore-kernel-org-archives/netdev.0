From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 06 May 2009 15:37:14 -0700 (PDT)
Message-ID: <20090506.153714.122287244.davem@davemloft.net>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
	<1241586309-12112-5-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753858AbZEFWhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:37:18 -0400
In-Reply-To: <1241586309-12112-5-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue,  5 May 2009 22:05:09 -0700

> There's no advantage of receive side scaling on GbE ports, so
> restrict rss support to 10GbE ports.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

This is your opinion.  And even if it is more than opinion,
you give zero technical arguments in your commit message so
we can see why this should be done.

Tell that opinion to the person with 10 netxen cards in their
machine running at full tilt.

Tell that opinion to the person with extremely complicated and
cpu intensive netfilter and routing rules in use.

I'm not applying this patch.
