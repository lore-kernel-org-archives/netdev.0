From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v1 0/2] The Long Lost TUN LSM Hooks
Date: Wed, 5 Aug 2009 10:43:03 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0908051035530.29562@tundra.namei.org>
References: <20090804211304.10798.65601.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090804211304.10798.65601.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Aug 2009, Paul Moore wrote:

> While drivers in general aren't good places for LSM hooks the TUN driver is
> a bit different because of how it handles sockets and network traffic.  The
> problem lies in the fact that the TUN driver creates a sock structure to use
> when sending network traffic but the sock is never put through the same LSM
> setup/control as other sock structures on the system which makes enforcing
> security on TUN generated traffic difficult for some LSMs.  This patch set
> adds three new LSM hooks, all specific to the TUN driver (none of the existing
> hooks made sense, trust me we tried), to control and monitor the creating and
> attachment of TUN devices.

Looks ok to me in principle.

For netdev reviewers: we're lacking proper LSM control over tun devices 
because they're not created like normal sockets, and subsequently don't 
get labeled appropriately.  They also behave differently to normal sockets 
and need special handling for security per Paul's notes.


- James
-- 
James Morris
<jmorris@namei.org>
