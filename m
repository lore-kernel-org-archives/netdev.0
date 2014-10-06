From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] ipv6: don't walk node's leaf during serial
 number update
Date: Mon, 06 Oct 2014 20:02:54 +0200
Message-ID: <1412618574.3403.29.camel@localhost>
References: <cover.1412585162.git.hannes@stressinduktion.org>
	 <60321af8a7305bec398e62858ef53bb6605878fb.1412585163.git.hannes@stressinduktion.org>
	 <CAHA+R7O2GYo6vTpm9uYPVE+jamdYRPEZo5301=NnL+Zw7vmxpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, hideaki@yoshifuji.org,
	kafai@fb.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46362 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbaJFSC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 14:02:56 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id F2EDB208E1
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 14:02:55 -0400 (EDT)
In-Reply-To: <CAHA+R7O2GYo6vTpm9uYPVE+jamdYRPEZo5301=NnL+Zw7vmxpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-10-06 at 10:58 -0700, Cong Wang wrote:
> On Mon, Oct 6, 2014 at 1:52 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > @@ -105,6 +106,10 @@ static int fib6_new_sernum(struct net *net)
> >         return new;
> >  }
> >
> > +enum {
> > +       FIB6_NO_SERNUM_CHANGE = 0,
> > +};
> > +
> 
> Not sure if it worth an enum definition... seems overkill for me.

Yeah, maybe, I was used to do it like that in user space because of
debuggers.

I think it is ok, also I just send v2 with your proposed changes.
If you have a strong opinion about that, let me know. ;)

Thanks a lot for the review,
Hannes
