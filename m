From: jamal <hadi@cyberus.ca>
Subject: Billing 1: WAS (Re: [PATCH 2/4] deferred drop, __parent
	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 22 Aug 2004 11:17:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093187835.1042.95.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <41220AEA.20409@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Apologies for latency - was busy at (my real) work.

Let me break this email into several ones since it is getting long.

On Tue, 2004-08-17 at 09:40, sandr8 wrote:

> something like enqueue(dev) that will indirectly call dev->qdisc->enqueue
> and handle in that single place that stuff that does not fit well in 
> net/core/dev.c

Enqueue of _root_ qdisc is the place to do it.
Maybe even dev.c calls to it. Lets defer this to the next email.

Let me say this:
I am happy with Haralds billing patch which is already in as is.
In other words, although there is an accounting discrepancy it is not
that big.
What does that mean? unbilling is not something to rush in and patch in
if its going to have an impact on other pieces. It doesnt matter whether
it goes in in 2.6.20 or doesnt even go in as far as i am concerned. 
However this shouldnt dicourage you because you have actually opened an
issue we need to resolve. So please keep up the discussions.

cheers,
jamal
