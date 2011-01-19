From: jamal <hadi@cyberus.ca>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 09:28:06 -0500
Message-ID: <1295447286.2008.850.camel@mojatatu>
References: <4D336050.9030602@netfilter.org>
	 <20110118093811.GA7520@ff.dom.local>
	 <20110118.020702.115924992.davem@davemloft.net>
	 <20110118102437.GB7520@ff.dom.local> <4D35F8A3.1010600@netfilter.org>
	 <20110118205507.GB4288@del.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45048 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab1ASO2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 09:28:14 -0500
Received: by vws16 with SMTP id 16so292043vws.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 06:28:14 -0800 (PST)
In-Reply-To: <20110118205507.GB4288@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 21:55 +0100, Jarek Poplawski wrote:
> On Tue, Jan 18, 2011 at 09:31:31PM +0100, Pablo Neira Ayuso wrote:

> > The combination that avahi uses makes no sense.
> 
> I don't agree as explained in the reverting patch. Anyway, again,
> this is an old problem, so no reason to force "fixing" it just now
> at the expense of the obvious regression especially in stable kernels
> Anyway, I'll accept any David's decision wrt this problem.
> 

So here is what i think the criteria should be:

If Avahi is popular and widely deployed (I dont use it anywhere), it
makes no sense to revert. 
A middle ground is: instead of rejecting the nonsense passed, maybe a
sane thing to do is a kernel warning for a period of time (sort of like
feature removal warnings).

The only way to keep the patch IMO (if avahi is widely deployed) is if
common distro policy is such that they will immediately fix and
distribute a new avahi even when this breakage is with a kernel that
distro wont support for  a year.

hope i am making sense.

cheers,
jamal

