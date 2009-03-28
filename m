From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/6] Labeled networking patches for 2.6.30
Date: Sat, 28 Mar 2009 11:58:52 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0903281158010.21619@tundra.namei.org>
References: <20090327205520.17777.32557.stgit@flek.lan> <20090327.145840.218658417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	casey@schaufler-ca.com, etienne.basset@numericable.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090327.145840.218658417.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Mar 2009, David Miller wrote:

> From: Paul Moore <paul.moore@hp.com>
> Date: Fri, 27 Mar 2009 17:10:20 -0400
> 
> > This patchset wraps up all the new labeled networking bits for 2.6.30.  This
> > is mostly a fixup/cleanup release with the main focus being to correct the
> > TCP labeling of both SELinux and Smack; expect some of this to get backported
> > to the -stable trees but there will need to be a bit of rework first so it
> > may take a few weeks for that to happen.  Other than the TCP issue there is a
> > new Smack feature to configure CIPSO aware hosts in "/smack/netlabel" which
> > should make the host/network label configuration much more flexible.  The last
> > change is to get rid of the security_socket_post_accept() hook which isn't
> > currently being used by anything in-tree and seems to act as a magnet for
> > bad ideas; if things change we can always add it back later.
> 
> Is James Morris going to take this stuff?  Just curious...

I will unless you specifically want it.

Paul: it's probably a good idea to have this in my tree before the merge 
window opens.


- James
-- 
James Morris
<jmorris@namei.org>
