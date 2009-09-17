From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: fanotify as syscalls
Date: Thu, 17 Sep 2009 19:35:43 +0200
Message-ID: <20090917193543.5f88e2b1@infradead.org>
References: <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
	<20090911212731.GA19901@shareable.org>
	<1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	<20090912094110.GB24709@ioremap.net>
	<20090914001759.GB30621@shareable.org>
	<20090914140720.GA8564@ioremap.net>
	<1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
	<20090915201620.GB32192@ioremap.net>
	<1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
	<20090916120523.GA12830@ioremap.net>
	<20090916122723.GE29359@shareable.org>
	<alpine.LFD.2.01.0909170934450.4950@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Eric Paris <eparis@redhat.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.01.0909170934450.4950@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Sep 2009 09:40:16 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> And then we have page faults. I've long wished that from a system
> call tracing standpoint we could show page faults as
> pseudo-system-calls (at least as long as they happen from user space
> - trying to handle nesting is not worth it). It would make it _so_
> much more obvious what the performance patterns are if you could just
> do
> 
> 	strace -ttT firefox
> 
> for the cold-cache case and you'd see where the time is really spent.
> 
> (yeah, yeah, you can get that kind of information other ways, but
> it's a hell of a lot less convenient than just getting a nice trace
> with timestamps).

ohhh I should add pagefaults to timechart
good one.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
