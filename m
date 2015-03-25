From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix ipv4 mapped request socks
Date: Wed, 25 Mar 2015 09:48:41 -0700
Message-ID: <1427302121.25985.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150325.005738.199321600853824869.davem@davemloft.net>
	 <1427260862.25985.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150325054837.GA790@localhost.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36250 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbbCYQsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 12:48:45 -0400
Received: by igbud6 with SMTP id ud6so106746698igb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 09:48:44 -0700 (PDT)
In-Reply-To: <20150325054837.GA790@localhost.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-24 at 22:48 -0700, Alexei Starovoitov wrote:

> btw, the following time saving steps were useful to me:
> 
> 1. add to your ~/.gitconfig
> [core]
>         abbrev = 12
> [pretty]
>         fixes = Fixes: %h (\"%s\")
> 
> 2. when bad commit is found do:
> $ git log -1 --pretty=fixes 3f66b083a5b7f1a63540c24df3679c24f
> 
> which will print:
> 
> Fixes: 3f66b083a5b7 ("inet: introduce ireq_family")
> 
> 3. copy-paste that line into your patch

Nice trick ! You should capture it somehow in Documentation/... !
