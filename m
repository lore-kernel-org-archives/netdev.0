From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] (02/15/08 Linus git) Smack unlabeled outgoing ambient packets - v4
Date: Fri, 15 Feb 2008 20:36:10 -0800 (PST)
Message-ID: <998774.580.qm@web36608.mail.mud.yahoo.com>
References: <200802152213.11661.paul.moore@hp.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>, casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from web36608.mail.mud.yahoo.com ([209.191.85.25]:20004 "HELO
	web36608.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752950AbYBPEgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 23:36:11 -0500
In-Reply-To: <200802152213.11661.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- Paul Moore <paul.moore@hp.com> wrote:

> On Friday 15 February 2008 6:24:25 pm Casey Schaufler wrote:
> > From: Casey Schaufler <casey@schaufler-ca.com>
> >
> > Smack uses CIPSO labeling, but allows for unlabeled packets
> > by specifying an "ambient" label that is applied to incoming
> > unlabeled packets. Because the other end of the connection
> > may dislike IP options, and ssh is one know application that
> > behaves thus, it is prudent to respond in kind. This patch
> > changes the network labeling behavior such that an outgoing
> > packet that would be given a CIPSO label that matches the
> > ambient label is left unlabeled. An "unlbl" domain is added
> > and the netlabel defaulting mechanism invoked rather than
> > assuming that everything is CIPSO. Locking has been added
> > around changes to the ambient label as the mechanisms used
> > to do so are more involved.
> >
> > Cleaned up some issues noted in review.
> > Make smk_cipso_doi() static.
> > Create a hook for the new security_secctx_to_secid()
> > using existing underlying code.
> > Fill in audit data for netlbl domain calls.
> > Collapse unnecessary multiple assignments.
> >
> > Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
> 
> Looks good to me, thanks for making those changes.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Thank you for the insights.


Casey Schaufler
casey@schaufler-ca.com
