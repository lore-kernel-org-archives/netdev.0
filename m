From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/3] ss: allow AF_FAMILY constants >32
Date: Wed, 4 Oct 2017 08:14:50 -0700
Message-ID: <20171004081450.20973fe8@xeon-e3>
References: <20171003175744.24987-1-stefanha@redhat.com>
        <20171003175744.24987-2-stefanha@redhat.com>
        <20171003112653.213c7cb3@xeon-e3>
        <20171004150119.GA3840@stefanha-x1.localdomain>
        <063D6719AE5E284EB5DD2968C1650D6DD0089AB4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Stefan Hajnoczi' <stefanha@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:50389 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752473AbdJDPOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:14:53 -0400
Received: by mail-pf0-f175.google.com with SMTP id m63so6401357pfk.7
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 08:14:53 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0089AB4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Oct 2017 15:03:09 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Stefan Hajnoczi
> > Sent: 04 October 2017 16:01  
> ...
> > > > --- a/misc/ss.c
> > > > +++ b/misc/ss.c
> > > > @@ -170,55 +170,57 @@ enum {
> > > >  struct filter {
> > > >  	int dbs;
> > > >  	int states;
> > > > -	int families;
> > > > +	__u64 families;  
> > >
> > > Since this isn't a value that is coming from kernel. It should be uint64_t
> > > rather than __u64.  
> > 
> > Okay, will fix in v2.  
> 
> But that looks like a kernel structure, not one exposed to userspace.
> So surely __u64 is correct.
> 
> 	David
> 

families is a bit field which is built from data, not from kernel.
