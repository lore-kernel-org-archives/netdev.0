From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] remove net/README
Date: Fri, 5 Sep 2003 11:22:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905112242.2ad1a358.ak@suse.de>
References: <20030904145204.GA27953@compsoc.man.ac.uk>
	<20030904074520.5dceff3e.davem@redhat.com>
	<20030905010725.5ee10cbf.ak@suse.de>
	<20030904225823.68a7b7cd.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030904225823.68a7b7cd.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003 22:58:23 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Fri, 5 Sep 2003 01:07:25 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > When you're doing janitor type stuff currently I would also suggest
> > an update of the NET4 version numbers:
> 
> I don't think we need to print all this crap out at all.

Makes sense. Especially since the version numbers tended to be stale
traditionally.

I would keep at least one printk for high level networking so that we know 
it has started (useful to get some clue where we are on a total
hang) 

One small disadvantage when e.g. the appletalk or ipx printks
are killed is that you cannot check if the user has compiled them
in or loaded. But that's probably tolerable. If it should be a 
problem a /proc/net/protocols would be probably a better solution.

Are you doing it or should I send a patch?

-Andi
