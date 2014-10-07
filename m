From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 7 Oct 2014 20:37:00 +0200
Message-ID: <20141007203700.00e883a1@redhat.com>
References: <20141007153050.792c9743@redhat.com>
	<1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	<1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007.131938.1410434352331637585.davem@davemloft.net>
	<1412703132.11091.144.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754793AbaJGSh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 14:37:59 -0400
In-Reply-To: <1412703132.11091.144.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2014 10:32:12 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2014-10-07 at 13:19 -0400, David Miller wrote:
> 
> > Yes, this makes sense, do a full qdisc_restart() cycle without boundaries,
> > then check how much quota was used afterwards to guard the outermost loop.
> 
> I am testing this, and also am testing the xmit_more patch for I40E.

Check, I'm also testing both yours and Hannes patch.

Results at:
 http://people.netfilter.org/hawk/qdisc/measure18_restore_quota_fairness/
 http://people.netfilter.org/hawk/qdisc/measure19_restore_quota_erics/
 http://people.netfilter.org/hawk/qdisc/measure20_no_quota_baseline_at_git_02c0fc1/

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
