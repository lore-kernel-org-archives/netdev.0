From: Paul Martin <pm@debian.org>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
 traffic
Date: Sun, 28 Jun 2009 11:28:09 +0100
Message-ID: <20090628102808.GA4533@nowster.org.uk>
References: <bug-13627-10286@http.bugzilla.kernel.org/>
 <20090626124444.c24d9b38.akpm@linux-foundation.org>
 <20090627020403.GB19639@gondor.apana.org.au>
 <20090626.192247.17381002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org, olver@hartkopp.net,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nowster.zetnet.co.uk ([194.247.42.226]:34485 "EHLO
	nowster.zetnet.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbZF1LHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 07:07:31 -0400
Content-Disposition: inline
In-Reply-To: <20090626.192247.17381002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 07:22:47PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 27 Jun 2009 10:04:03 +0800

> > inet: Call skb_orphan before tproxy activates

> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, thanks Herbert.

Checked. It fixes the problem for me.

-- 
Paul Martin <pm@debian.org>
