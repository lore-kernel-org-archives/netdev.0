From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 01 Dec 2015 17:02:23 +0100
Message-ID: <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
References: <20151201120420.GT12404@principal.rfc2324.org>
 <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Maximilian Wilhelm <max@rfc2324.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:47538 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754703AbbLAQCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 11:02:24 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 01FE321042
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 11:02:23 -0500 (EST)
In-Reply-To: <20151201155052.GA14984@principal.rfc2324.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
> > I'm not sure I understand how this would work- are we going to 
> > pin down the ifindex for some subset of interfaces?
> 
> I'm not sure what your idea is, but I guess we might mean the same
> thing:
> 
> What I have in mind is that the user can supply a list of (ifname ->
> ifindex) entries via a sysfs/procfs interface and if such a list is
> present, the kernel will search the list for every ifname which is
> registered and check if there is an entry. If there is, the ifindex
> for this entry is used. If there is no entry found for the given
> ifname, the usual algorithm is used (therefore inherently providing
> backward compatibility).

Sorry to ask because I don't like this feature at all. There was a lot
of work on stable interface names. Why do you need stable ifindexes,
which were never meant to be stable for a longer amount of time?

Bye,
Hannes
