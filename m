From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: Re: AF_BUS socket address family
Date: Sat, 30 Jun 2012 00:22:28 +0100
Message-ID: <20120629232227.GB28593@mail.collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
 <4FEDF7B6.3020107@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FEDF7B6.3020107@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2012 at 11:45:10AM -0700, Casey Schaufler wrote:
> On 6/29/2012 9:45 AM, Vincent Sanders wrote:

<snip>

> >
> > A socket created using BUS_PROTO_DBUS indicates that the messages
> > passed will be in the D-Bus format. The userspace libraries have been
> > updated to use this transport with an updated D-Bus daemon [2] as a bus
> > master.
> 
> Why don't you go whole hog and put all of D-Bus into the kernel?
> 

That would be ridiculously excessive. This work represents what we
feel is the minimum required functionlity for the underlying IPC
mechanism. 

The minimal filtering performed by the netfilter module is what is
required to enforce security as used in existing deployments and no more.

<snip>

> >
> > The tools for testing these assertions are available [3] and
> > consistently show a doubling in throughput and better than halving of
> > latency.
> 
> Please cross-post Patches 04/15 and 05/15 to the linux-security-module list.
> Please cross-post Patch 05/15 to the selinux list.
> 
> Where is the analogous patch for the Smack LSM?

we have not tested or built this with the Smack LSM, I would, of
course, be pleased to accept a patch to add this functionality if you
are knowladgeable in this area.

<snip>
