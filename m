From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 11/16] netlabel: Add functionality to set the security attributes of a packet
Date: Wed, 1 Oct 2008 12:51:12 -0400
Message-ID: <200810011251.12898.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125701.17132.46623.stgit@flek.lan> <alpine.LRH.1.10.0810011952100.6732@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.1.10.0810011952100.6732@tundra.namei.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 October 2008 5:55:49 am James Morris wrote:
> It might be better in the long term to integrate this stuff more
> directly with the core networking.

Agreed.  I did it the way I did because I wanted to impact the core 
stack as little as possible.  I looked at potentially doing the work in 
ip_options_compile() but that was going to require a lot of tweaking 
and some rather ugly hacks to keep everything contained and off to the 
side.  Tighter integration with the core stack can always be treated as 
an optimization at a later date; I want to see what our IPv6 needs will 
be first and I don't have a clear picture of that just yet.

On the plus side, only traffic coming from unconnected sockets is going 
to be hit by this and with most stuff using TCP these days I'm hopeful 
that the impact to the SELinux folks using labeled networking will be 
_relatively_ minimal.

-- 
paul moore
linux @ hp
