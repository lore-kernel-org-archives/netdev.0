From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
	non-drops and modifying end-of-line points for skbs
Date: Wed, 4 Mar 2009 19:45:05 -0300
Message-ID: <20090304224505.GD6392@ghostprotocols.net>
References: <20090304135415.GB6392@ghostprotocols.net> <20090304141831.GB6139@hmsreliant.think-freely.org> <20090304161335.GC6392@ghostprotocols.net> <20090304.130614.127792905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36337 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbZCDWqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2009 17:46:00 -0500
Content-Disposition: inline
In-Reply-To: <20090304.130614.127792905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Mar 04, 2009 at 01:06:14PM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Wed, 4 Mar 2009 13:13:35 -0300
> 
> > I wouldn't mind the churn, as I really think drop_skb() would be
> > clearer, but then this is up to Dave.
> 
> I mind the churn, I have to apply this thing and deal with
> the merge conflicts :-)
> 
> Why not come up with a clever alternative name for kfree_skb_clean()?

Oh well, sometimes churn is inevitable, but lemme try to figure out some
more clearer names for kfree_skb_clean:

rest_in_peace_skb()
here_lies_a_productive_skb()
kfree_not_dropped_skb()
kfree_worthy_skb()
consumed_skb()
hasta_la_vista_skbaby()
kfree_used_skb()

Perhaps the last one, huh? :-)

- Arnaldo

P.S.: </joke'ishy moment>
