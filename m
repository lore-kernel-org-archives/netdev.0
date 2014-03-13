From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 15:53:49 -0400
Message-ID: <20140313195349.GM18914@redhat.com>
References: <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org>
 <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org>
 <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
 <1394675038.32465.223.camel@willson.li.ssimo.org>
 <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
 <1394733077.32465.243.camel@willson.li.ssimo.org>
 <CALCETrXWzja6W6y=p9MrtynGZMsrD5KQu0KBK6Bs1dQxnesv2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXWzja6W6y=p9MrtynGZMsrD5KQu0KBK6Bs1dQxnesv2A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 13, 2014 at 10:55:16AM -0700, Andy Lutomirski wrote:

[..]
> >> 2. Docker is a container system, so use the "container" (aka
> >> namespace) APIs.  There are probably several clever things that could
> >> be done with /proc/<pid>/ns.
> >
> > pid is racy, if it weren't I would simply go straight
> > to /proc/<pid>/cgroups ...
> 
> How about:
> 
> open("/proc/self/ns/ipc", O_RDONLY);
> send the result over SCM_RIGHTS?

As I don't know I will ask. So what will server now do with this file
descriptor of client's ipc namespace.

IOW, what information/identifier does it contain which can be
used to map to pre-configrued per container/per namespace policies.

Thanks
Vivek
