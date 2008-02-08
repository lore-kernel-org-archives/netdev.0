From: Paul Moore <paul.moore@hp.com>
Subject: Re: + smack-unlabeled-outgoing-ambient-packets.patch added to -mm tree
Date: Fri, 8 Feb 2008 12:43:52 -0500
Message-ID: <200802081243.52504.paul.moore@hp.com>
References: <200802071901.m17J1lAY016751@imap1.linux-foundation.org> <200802071450.41529.paul.moore@hp.com> <20080207120459.d4994f44.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jmorris@namei.org, mingo@elte.hu, sds@tycho.nsa.gov,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:35007 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbYBHRn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 12:43:57 -0500
In-Reply-To: <20080207120459.d4994f44.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > ------------------------------------------------------
> > > Subject: Smack: unlabeled outgoing ambient packets
> > > From: Casey Schaufler <casey@schaufler-ca.com>
> > >
> > > Smack uses CIPSO labeling, but allows for unlabeled packets by
> > > specifying an "ambient" label that is applied to incoming
> > > unlabeled packets.  Because the other end of the connection may
> > > dislike IP options, and ssh is one know application that behaves
> > > thus ...

I forgot to mention this earlier, but RHEL/Fedora/Rawhide has a patched 
version of SSH (see RH bugzilla #202856 for the discussion/patch) that 
fixes the problem of IPv4 options causing SSH to reject the connection.  
It turns out that SSH is being a bit overzealous (rejecting all IPv4 
options) in trying to reject source-routed packets.

-- 
paul moore
linux security @ hp
