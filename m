From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 11:13:27 -0400
Message-ID: <200607151113.27922.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <Pine.LNX.4.64.0607150905550.24495@d.namei> <Pine.LNX.4.64.0607150911210.24495@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:59305 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1750709AbWGOPNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 11:13:34 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607150911210.24495@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 15 July 2006 9:11 am, James Morris wrote:
> On Sat, 15 Jul 2006, James Morris wrote:
> > > +	/* XXX - In both cases, this is kinda ugly as we have to go through
> > > +	   the list once to determine how large of a buffer we need,
> > > +	   drop the locks, allocate the buffer, grab the locks, and
> > > +	   finally fill the buffer.  The problem is that there is that
> > > +	   open window where the table could grow and we will end up
> > > +	   short on space. */
> >
> > This needs to be fixed.
>
> Actually, you have many of these.

I believe there are a total of four, the two you just found in 
net/ipv4/cipso_ipv4.c and two more in net/netlabel/netlabel_domainhash.c.  I 
will fix all of them for the next submission of the patchset.

-- 
paul moore
linux security @ hp
