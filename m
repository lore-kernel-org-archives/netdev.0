From: "Laurent Chavey" <chavey@google.com>
Subject: Re: is CONFIG_NET_CLS_ACT always set ?
Date: Mon, 23 Apr 2007 16:08:37 -0700
Message-ID: <97949e3e0704231608n6f43807en1ee6e27265c641ba@mail.gmail.com>
References: <97949e3e0704231419o21062b6cl5b8cf38e1b412b05@mail.gmail.com>
	 <1177369190.4096.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14298 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbXDWXIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 19:08:50 -0400
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id l3NN8eFS000338
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 00:08:40 +0100
Received: from ik-out-1112.google.com (ikac29.prod.google.com [10.68.54.29])
	by spaceape7.eur.corp.google.com with ESMTP id l3NN8cOw003992
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 00:08:38 +0100
Received: by ik-out-1112.google.com with SMTP id c29so1947557ika
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 16:08:38 -0700 (PDT)
In-Reply-To: <1177369190.4096.13.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sorry for the trick question.

I was simply making a modification to the skb tap code
to allow tcpdump to work on the slave interface and not
just the bonded one. The code change requires a change to
the for loop code and it follow on to the call to deliver_skb().

In the process of adding the code, I noticed that if (at least
that is how I read the code)
CONFIG_NET_CLS_ACT is not defined then
the last pt_prev is call after the diverter and bridge code
have handled the skb.  This would only occur for bridged skb
that one wanted to tap.



On 4/23/07, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2007-23-04 at 14:19 -0700, Laurent Chavey wrote:
> > if CONFIG_NET_CLS_ACT is not defined, then is the
> > code below correct ?
>
> The simple answer is yes;
> Is something not working for you?
>
> It is hard to read your question my good friend because it comes out
> like a trick question;->
> It is more useful to say:
>  "I think this code is broken because ...."
> And even more useful if you add:
> "I have run the following testcases to illustrate blah ..."
> Then if something is broken, and you want to be popular, you say:
> "netdevers, heres the fix"
>
> Anyways, what is the problem?
>
> cheers,
> jamal
>
>
