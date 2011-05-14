From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Fri, 13 May 2011 17:32:13 -0700
Message-ID: <20110513173213.491c74a1@nehalam>
References: <20110513171729.247b126e@nehalam>
	<1305332905.8149.705.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59306 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758788Ab1ENAcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 20:32:19 -0400
In-Reply-To: <1305332905.8149.705.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 May 2011 17:28:25 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> On Fri, 2011-05-13 at 17:17 -0700, Stephen Hemminger wrote:
> > There are some addresses in the assigned vendor block that don't obey
> > the locally assigned convention. These should be avoided by random_ether_addr
> > assignment.
> 
> How "recent" are these violations?  Is there really a non-trivial chance
> of colliding?  Much more than two or more stations in the same broadcast
> domain randomly picking the same random MAC anyway?
> 
> At one level, avoiding using those OUIs seems to be a tacit approval of
> the violations.

These were assigned long ago in the early days of Ethernet.
It makes sense to me to avoid them as just good policy.


-- 
