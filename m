From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Sun, 23 Nov 2014 00:22:00 -0500 (EST)
Message-ID: <1279921267.2842813.1416720120277.JavaMail.zimbra@redhat.com>
References: <1416327778-17716-1-git-send-email-pagupta@redhat.com> <20141119.151628.768548269128919029.davem@davemloft.net> <20141119204427.GB30994@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jasowang@redhat.com, dgibson@redhat.com, vfalico@gmail.com,
	edumazet@google.com, vyasevic@redhat.com, hkchu@google.com,
	wuzhy@linux.vnet.ibm.com, xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei shtylyov <sergei.shtylyov@cogentembedded.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141119204427.GB30994@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Wed, Nov 19, 2014 at 03:16:28PM -0500, David Miller wrote:
> > From: Pankaj Gupta <pagupta@redhat.com>
> > Date: Tue, 18 Nov 2014 21:52:54 +0530
> > 
> > > - Accept maximum number of queues as sysctl param so that any user space
> > >   application like libvirt can use this value to limit number of queues.
> > >   Also
> > >   Administrators can specify maximum number of queues by updating this
> > >   sysctl
> > >   entry.
> > 
> > This is the only part I don't like.
> > 
> > Just let whoever has privileges to configure the tun device shoot
> > themselves in the foot if they want to by configuring "too many"
> > queues.
> > 
> > If the virtual entity runs itself out of resources by doing something
> > stupid, it's purely their problem.

We can configure some fixed number of queues like 16 or so at the start 
if multiqueue is enabled and then if somebody needs more then that, they
can do on their own.

If we dont want anyone to directly increase the number of queues, we can add
an ioctl command for increasing number of queues?



Suggestions here. 
> 
> Well it will run host out of kernel, no?
> 
> --
> MST
> 
