From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Wed, 09 Oct 2013 17:12:40 -0700
Message-ID: <1381363960.4971.55.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
	 <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
	 <1381354186-16285-7-git-send-email-paulmck@linux.vnet.ibm.com>
	 <1381354949.4971.20.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009215747.GA5790@linux.vnet.ibm.com>
	 <1381356624.4971.26.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009223652.GC5790@linux.vnet.ibm.com>
	 <1381359077.4971.37.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009225617.GH11709@jtriplet-mobl1>
	 <1381360675.4971.45.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009234040.GB14055@jtriplet-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	mingo@kernel.org, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com,
	darren@dvhart.com, fweisbec@gmail.com, sbw@mit.edu,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:58567 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223Ab3JJAMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 20:12:43 -0400
In-Reply-To: <20131009234040.GB14055@jtriplet-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 16:40 -0700, Josh Triplett wrote:

> that.  Constructs like list_del_rcu are much clearer, and not
> open-coded.  Open-coding synchronization code is almost always a Bad
> Idea.

OK, so you think there is synchronization code.

I will shut up then, no need to waste time.
