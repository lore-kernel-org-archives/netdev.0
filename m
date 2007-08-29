From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [patch 0/1][RFC] add a private field to the sock structure
Date: Wed, 29 Aug 2007 16:18:31 -0300
Message-ID: <20070829191831.GA16184@ghostprotocols.net>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com> <20070829.112316.98862875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org, ralf@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.227]:53884 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbXH2TSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 15:18:48 -0400
Received: by qb-out-0506.google.com with SMTP id e11so366671qbe
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 12:18:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070829.112316.98862875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Aug 29, 2007 at 11:23:16AM -0700, David Miller escreveu:
> From: dlezcano@fr.ibm.com
> Date: Wed, 29 Aug 2007 18:41:14 +0200
> 
> > When a socket is created it is sometime useful to store a specific information
> > for this socket.
> >  
> > This information can be for examples: 
> > 	* a creation time
> > 	* a pid
> > 	* a uid/gid
> > 	* a container identifier
> > 	* a pointer to a more specific structure
> > 	* ...
> > 
> > The following patch is a proposition to add a private anonymous pointer
> > field to the common part of the sock structure.
> 
> We got rid of the private field a long time ago because not only
> is it not needed, it tends to get abused.

Nah, it still there, sk_protinfo, its just ax25 that uses it
(nudge(Ralf)). How do we state that a struct field is deprecated and
will be removed soon(tm)?

There is another, sk_user_data, that is used only by the rpc, pppol2tp,
iscsi, ncpfs, smbfs and dlm guys, see? We need a deprecate flag for
sk_protinfo, if not people will use it! :-)

- Arnaldo
