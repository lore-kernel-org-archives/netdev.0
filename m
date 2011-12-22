From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Partial revert "Basic kernel memory functionality for
 the Memory Controller"
Date: Thu, 22 Dec 2011 11:59:37 +0100
Message-ID: <20111222105937.GC8833@tiehlicka.suse.cz>
References: <1324543990-27784-1-git-send-email-glommer@parallels.com>
 <20111222104339.GA8833@tiehlicka.suse.cz>
 <4EF309F0.90407@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, cgroups@vger.kernel.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Paul Menage <paul@paulmenage.org>,
	Greg Thelen <gthelen@google.com>,
	Johannes Weiner <jweiner@redhat.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40324 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149Ab1LVK7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 05:59:40 -0500
Content-Disposition: inline
In-Reply-To: <4EF309F0.90407@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu 22-12-11 14:44:00, Glauber Costa wrote:
> On 12/22/2011 02:43 PM, Michal Hocko wrote:
> >On Thu 22-12-11 12:53:10, Glauber Costa wrote:
> >>This reverts commit e5671dfae59b165e2adfd4dfbdeab11ac8db5bda.
> >>
> >>After a follow up discussion with Michal, it was agreed it would
> >>be better to leave the kmem controller with just the tcp files,
> >>deferring the behavior of the other general memory.kmem.* files
> >>for a later time, when more caches are controlled.
> >
> >"Because generic kmem files are not used by tcp accounting and it is
> >not clear how other slab caches would fit into the scheme."
> 
> Should I respin?

Yes, please
[...]

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
