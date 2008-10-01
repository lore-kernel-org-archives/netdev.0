From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 02/16] selinux: Correctly handle IPv4 packets on
 IPv6 sockets in all cases
Date: Wed, 1 Oct 2008 11:36:57 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011136230.5277@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125601.17132.61002.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125601.17132.61002.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> We did the right thing in a few cases but there were several areas where we
> determined a packet's address family based on the socket's address family which
> is not the right thing to do since we can get IPv4 packets on IPv6 sockets.
> This patch fixes these problems by either taking the address family directly
> from the packet.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
