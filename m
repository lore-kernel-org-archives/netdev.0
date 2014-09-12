From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of
 pkt_type_offset
Date: Fri, 12 Sep 2014 19:09:48 +0200
Message-ID: <1410541788.2970.2.camel@localhost>
References: <5412D9B9.2020300@redhat.com>
	 <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
	 <20140912160559.GA34038@its-macbook-pro.westell.com>
	 <CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43579 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbaILRJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 13:09:51 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 4F39320D2E
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:09:51 -0400 (EDT)
In-Reply-To: <CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-09-12 at 10:06 -0700, Cong Wang wrote:
> On Fri, Sep 12, 2014 at 9:06 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Fri, Sep 12, 2014 at 02:04:43PM +0200, Hannes Frederic Sowa wrote:
> >> Currently we have 2 pkt_type_offset functions doing the same thing and
> >> spread across the architecture files. Remove those and replace them
> >> with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
> >> zero sized sk_buff member right in front of the bitfield with offsetof.
> >> This new offset marker does not change size of struct sk_buff.
> >>
> >> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> >> Cc: Markos Chandras <markos.chandras@imgtec.com>
> >> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> >> Cc: Daniel Borkmann <dborkman@redhat.com>
> >> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> >> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> >> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> ---
> >>
> >> v2) Incorporated Daniel's feedback. I first misinterpreted the feedback
> >>     as something not related to pkt_type_offset.
> >
> > Thanks! It's a nice cleanup.
> >
> > Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> Wait... Isn't there a same patch before?
> 
> http://www.spinics.net/lists/netdev/msg294839.html
> 
> Maybe not exactly the same, but roughly same from the stats....

Sure, he asked me to send it and I included his signed-off. I think I
did that correctly?

Bye,
Hannes
