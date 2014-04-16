From: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 16 Apr 2014 12:54:01 -0400
Message-ID: <1397667241.19767.434.camel@willson.li.ssimo.org>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
	 <20140416002010.GA5035@redhat.com>
	 <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
	 <20140416.085743.1614257692560892039.davem@davemloft.net>
	 <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
	 <1397664837.19767.410.camel@willson.li.ssimo.org>
	 <20140416162149.GI1257@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140416162149.GI1257-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 12:21 -0400, Tejun Heo wrote:
> Hello,
> 
> On Wed, Apr 16, 2014 at 12:13:57PM -0400, Simo Sorce wrote:
> > The only one that *may* be reasonable is the "secret" cgroup name one,
> > however nobody seem to come up with a reason why it is legitimate to
> > allow to keep cgroup names secret.
> 
> Ugh, please don't play security games with cgroup names.  It is one of
> the identifying properties of a task, like a pid, and will be used in
> other parts of the kernel to match groups of tasks.  If we play
> security peekaboo with cgroup names, it has to be transitive and puts
> burdens on all its future uses.  Unless there are *REALLY* strong
> rationales, which can also justify hiding pids, this isn't happening.

FWIW, I totally agree with you, it's Andy Lutomirski that is coming up
with this "secret" cgropus name idea, nobody else (so far) seem to agree
it makes sense.

Simo.
