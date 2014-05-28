From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Tue, 27 May 2014 18:41:08 -0700
Message-ID: <1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:42292 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaE1BlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 21:41:12 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so10266806pbc.30
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 18:41:11 -0700 (PDT)
In-Reply-To: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-27 at 17:29 -0400, sowmini varadhan wrote:

> Has anyone looked at consolidating some of this?
> All of this could easily become a factor when the system
> has a large number of interfaces and addresses, and the
> control plane only wants to modify a very small subset of
> that state.

You did not provide kernel version you used.

Last time I checked, we were spending _lot_ of time in check_lifetime()

( this stuff was added in linux-3.9 )
