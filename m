From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 21:05:58 -0400
Message-ID: <20170425010558.GC24425@nvt-d.home.kvack.org>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        bcrl@kvack.org, Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33873 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979547AbdDYBGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 21:06:02 -0400
Received: by mail-io0-f175.google.com with SMTP id a103so205337491ioj.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 18:06:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 08:58:18PM -0400, Jamal Hadi Salim wrote:
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

What are the new rules for TLVs -- do you want a new type added for the 
subset values that are limited to the number of bits actually used?  A 
pointed here would be helpful.

		-ben

> cheers,
> jamal
