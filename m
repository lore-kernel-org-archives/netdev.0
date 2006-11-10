From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] dccp: remove module exit functions
Date: Fri, 10 Nov 2006 11:24:35 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611101122520.15046@d.namei>
References: <XMMS.LNX.4.64.0611100345300.10983@d.namei>
 <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "dccp (vger)" <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:24215 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1946757AbWKJQZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 11:25:29 -0500
To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
In-Reply-To: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006, Arnaldo Carvalho de Melo wrote:

> On 11/10/06, James Morris <jmorris@namei.org> wrote:
> > The dccp ipv4 & ipv6 modules cannot be unloaded, as their control sockets
> > each maintain a couple of module references.  So, it seems like a good
> > idea to just remove the module exit functions completely.
> > 
> > Please review.
> 
> Well, I have a patch in the DCCP backlog that uses it, ressurecting
> the unload hack, for development purposes being able to destroy the
> control sockets allowing module removal is something the DCCP
> developers want :)

I wonder if this facility can be integrated more generally into the kernel 
protocol which people are developing.

Where is the patch you use?



- James
-- 
James Morris
<jmorris@namei.org>
