From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 09:11:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607150911210.24495@d.namei>
References: <20060714185739.780700000@flek.zko.hp.com>
 <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607150905550.24495@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:41610 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161287AbWGONLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 09:11:41 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <Pine.LNX.4.64.0607150905550.24495@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 15 Jul 2006, James Morris wrote:

> > +	/* XXX - In both cases, this is kinda ugly as we have to go through
> > +	   the list once to determine how large of a buffer we need,
> > +	   drop the locks, allocate the buffer, grab the locks, and
> > +	   finally fill the buffer.  The problem is that there is that
> > +	   open window where the table could grow and we will end up
> > +	   short on space. */
> 
> This needs to be fixed.

Actually, you have many of these.


-- 
James Morris
<jmorris@namei.org>
