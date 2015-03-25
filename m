From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix ipv4 mapped request socks
Date: Tue, 24 Mar 2015 22:48:38 -0700
Message-ID: <20150325054837.GA790@localhost.westell.com>
References: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150325.005738.199321600853824869.davem@davemloft.net>
 <1427260862.25985.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34648 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbbCYFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 01:48:45 -0400
Received: by igcau2 with SMTP id au2so65012550igc.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 22:48:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427260862.25985.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 10:21:02PM -0700, Eric Dumazet wrote:
> On Wed, 2015-03-25 at 00:57 -0400, David Miller wrote:
> 
> > Applied, thanks Eric.
> > 
> > Please put the Fixes: tag before all the signoffs and acks
> > in the future, thanks in advance.
> 
> Sure, I will try to remember this rule ;)

btw, the following time saving steps were useful to me:

1. add to your ~/.gitconfig
[core]
        abbrev = 12
[pretty]
        fixes = Fixes: %h (\"%s\")

2. when bad commit is found do:
$ git log -1 --pretty=fixes 3f66b083a5b7f1a63540c24df3679c24f

which will print:

Fixes: 3f66b083a5b7 ("inet: introduce ireq_family")

3. copy-paste that line into your patch
