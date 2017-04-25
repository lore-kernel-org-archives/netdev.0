From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 18:20:54 -0700
Message-ID: <20170424182054.116d1a99@cakuba.netronome.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
        <20170424.143257.1003081554810761464.davem@davemloft.net>
        <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com,
        netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:43001 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S979618AbdDYBVT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 21:21:19 -0400
In-Reply-To: <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Apr 2017 20:58:18 -0400, Jamal Hadi Salim wrote:
> On 17-04-24 02:32 PM, David Miller wrote:
> > From: Benjamin LaHaise <benjamin.lahaise@netronome.com>  
> 
> >
> > Series applied, but in the future:
> >
> > 1) Put the "v2", "v3", whatever in the inital [PATCH xxx] bracketed
> >    part of the subject line, otherwise it ends up in the GIT commit
> >    message header line and that's not desired.
> >
> > 2) Please cut it with these double signoffs, and add an appropriate
> >    entry to the email aliases file.  
> 
> I know i should have spoken earlier, wanted to but got distracted - but
> shouldnt the new rules have applied to this patch too? ;->
> 
> You have 3 TLVs, one of which is u8 that only allows use of 3 bits.
> The other is a u32 which allows only 20 bits to be set.

I don't think we will ever reuse bits in a field which is called
MPLS_LABEL for anything else than an MPLS label.  My understanding of
the conclusions from recent discussions was to either (a) make
attributes single purpose (i.e. separate u8 per flag); or (b) make
attributes u32/word size but validate the unused bits are zero.  This
patch would fall under (a).
