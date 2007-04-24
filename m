From: jamal <hadi@cyberus.ca>
Subject: Re: is CONFIG_NET_CLS_ACT always set ?
Date: Mon, 23 Apr 2007 20:02:57 -0400
Message-ID: <1177372977.4096.24.camel@localhost>
References: <97949e3e0704231419o21062b6cl5b8cf38e1b412b05@mail.gmail.com>
	 <1177369190.4096.13.camel@localhost>
	 <97949e3e0704231608n6f43807en1ee6e27265c641ba@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:2581 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030881AbXDXADB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 20:03:01 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1985910wxd
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 17:03:01 -0700 (PDT)
In-Reply-To: <97949e3e0704231608n6f43807en1ee6e27265c641ba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-23-04 at 16:08 -0700, Laurent Chavey wrote:
> sorry for the trick question.
> 
> I was simply making a modification to the skb tap code
> to allow tcpdump to work on the slave interface and not
> just the bonded one. 

If you dont mind: what is the goal? I am not sure i want to see the
packets on a backup interface in a bond active/backup - but you may
have some good reason.

> The code change requires a change to
> the for loop code and it follow on to the call to deliver_skb().
> 

Iam assuming you have taken care of the code above that which drops the
packet if not destined for master? 

> In the process of adding the code, I noticed that if (at least
> that is how I read the code)
> CONFIG_NET_CLS_ACT is not defined then
> the last pt_prev is call after the diverter and bridge code
> have handled the skb.  This would only occur for bridged skb
> that one wanted to tap.
> 

The bridge code does the right thing if you follow handle bridge.
The old diverter (you must be looking at an old kernel, because it is
gone) was supposed to be able to steal packets.
I am not sure if that answers your question.

cheers,
jamal


