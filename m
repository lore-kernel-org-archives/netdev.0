From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 01/16] selinux: Cleanup the NetLabel glue code
Date: Wed, 1 Oct 2008 11:35:46 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011135140.5277@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125554.17132.61538.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125554.17132.61538.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> We were doing a lot of extra work in selinux_netlbl_sock_graft() what wasn't
> necessary so this patch removes that code.  It also removes the redundant
> second argument to selinux_netlbl_sock_setsid() which allows us to simplify a
> few other functions.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Nice cleanup :-)

Acked-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
