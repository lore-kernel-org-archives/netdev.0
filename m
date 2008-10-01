From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 09/16] netlabel: Add a generic way to create
 ordered linked lists of network addrs
Date: Wed, 1 Oct 2008 19:09:33 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011909000.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125646.17132.5022.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125646.17132.5022.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> Create an ordered IP address linked list mechanism similar to the core
> kernel's linked list construct.  The idea behind this list functionality
> is to create an extensibile linked list ordered by IP address mask to
> ease the matching of network addresses.  The linked list is ordered with
> larger address masks at the front of the list and shorter address masks
> at the end to facilitate overriding network entries with individual host
> or subnet entries.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> 

Reviewed-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
