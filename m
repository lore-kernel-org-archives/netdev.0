From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Wed, 12 Sep 2007 02:52:44 -0700 (PDT)
Message-ID: <20070912.025244.48515110.davem@davemloft.net>
References: <m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:48281
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764055AbXILJxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 05:53:15 -0400
In-Reply-To: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:15:34 -0600

> 
> This is the basic infrastructure needed to support network
> namespaces.  This infrastructure is:
> - Registration functions to support initializing per network
>   namespace data when a network namespaces is created or destroyed.
> 
> - struct net.  The network namespace data structure.
>   This structure will grow as variables are made per network
>   namespace but this is the minimal starting point.
> 
> - Functions to grab a reference to the network namespace.
>   I provide both get/put functions that keep a network namespace
>   from being freed.  And hold/release functions serve as weak references
>   and will warn if their count is not zero when the data structure
>   is freed.  Useful for dealing with more complicated data structures
>   like the ipv4 route cache.
> 
> - A list of all of the network namespaces so we can iterate over them.
> 
> - A slab for the network namespace data structure allowing leaks
>   to be spotted.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

I realize there are some discussions about naming and fixing
some races, but I applied this anyways so we can make some
forward progress.

We can make name changes and fixes on top of this initial work.
