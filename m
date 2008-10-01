From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 15/16] cipso: Add support for native local labeling
 and fixup mapping names
Date: Thu, 2 Oct 2008 08:12:16 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810020810570.12028@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125730.17132.74360.stgit@flek.lan> <alpine.LRH.1.10.0810012003170.6732@tundra.namei.org> <200810011305.04872.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200810011305.04872.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Oct 2008, Paul Moore wrote:

> > Macros would be nice for these ...
> 
> I assume you mean the "0x80" and "0x08" constants and not the function 
> itself? 

Yes.

> I ask because I remember reading that (macros == evil) because 
> of the lack of parameter type checking.
> 
> > ... and why specify zero filling?  (Setting and testing that would be
> > wasted cycles, if you enforced it). 
> 
> Better alignment within the IP option field, the goal being to try and 
> get the secid aligned on a 32bit boundary.  However, it just occurred 
> to me that by adding the two octets of padding I've actually pushed it 
> out of alignment (I forgot about the obligatory IP option type and 
> length octets).

I mean, why specify zero-filled rather than simply "unused" ?

> Man I hate IPv4 options, what a parsing nightmare ...

It was all fixed with IPv6, right? :-)


- James
-- 
James Morris
<jmorris@namei.org>
