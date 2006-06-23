From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 23 Jun 2006 19:24:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606231906380.6209@d.namei>
References: <20060621200031.589235000@flek.zko.hp.com>
 <20060622.021223.125894633.davem@davemloft.net>  <1151088481.2669.25.camel@localhost.localdomain>
  <20060623.131512.21593290.davem@davemloft.net> <1151094857.2669.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:10909 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750779AbWFWXYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 19:24:38 -0400
To: Ted <txtoth@gmail.com>
In-Reply-To: <1151094857.2669.51.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Jun 2006, Ted wrote:

> I can guarantee that initially SELinux adoption will be by those running
> trusted OSs and they will want their systems to be able to interoperate
> at level. The idea that IPSEC will fill this need in the near term is
> just not realistic.

SELinux is already being adopted for all kinds of needs.

In many cases, people have been using MLS because that's all there is in 
terms of MAC operating systems, and would actually be much better off with 
Type Enforcement for new deployments.

MLS solves a very narrow (albeit important) case, whereas TE is designed 
to be generic.  Typically, MLS is indicated when you have a very large 
number of domains to separate (e.g. many hundreds or thousands of 
compartments with hierarchical properites).  

SELinux provides MLS support, and has a generic labeled networking 
framework ("xfrm labeling").  Some further work is needed for xfrm 
labeling to provide a complete MLS solution, which TCS and co have been 
working on.

The general idea is that we're working on new, inherently flexible 
security schemes for Linux, which will meet a wider range of requirements 
and be available as standard features of mainstream distros.

Support for interoperability with legacy CIPSO systems is something that I 
think would be nice to have, if it can be done in a way which doesn't 
impact deeply on core kernel code, and plays nicely with native Linux 
infrastructure.



- James
-- 
James Morris
<jmorris@namei.org>
