From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2 1/3] ss: allow AF_FAMILY constants >32
Date: Wed, 4 Oct 2017 15:03:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0089AB4@AcuExch.aculab.com>
References: <20171003175744.24987-1-stefanha@redhat.com>
 <20171003175744.24987-2-stefanha@redhat.com>
 <20171003112653.213c7cb3@xeon-e3>
 <20171004150119.GA3840@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
To: 'Stefan Hajnoczi' <stefanha@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:51129 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752338AbdJDPDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:03:12 -0400
In-Reply-To: <20171004150119.GA3840@stefanha-x1.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi
> Sent: 04 October 2017 16:01
...
> > > --- a/misc/ss.c
> > > +++ b/misc/ss.c
> > > @@ -170,55 +170,57 @@ enum {
> > >  struct filter {
> > >  	int dbs;
> > >  	int states;
> > > -	int families;
> > > +	__u64 families;
> >
> > Since this isn't a value that is coming from kernel. It should be uint64_t
> > rather than __u64.
> 
> Okay, will fix in v2.

But that looks like a kernel structure, not one exposed to userspace.
So surely __u64 is correct.

	David
