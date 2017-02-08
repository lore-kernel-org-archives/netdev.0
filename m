From: David Miller <davem@davemloft.net>
Subject: Re: ip route add give rtnetlink message after update from 4.9.6 to
 4.9.8
Date: Wed, 08 Feb 2017 10:44:43 -0500 (EST)
Message-ID: <20170208.104443.1740615905192284560.davem@davemloft.net>
References: <224940468.86611486549068694.JavaMail.httpd@webmail-37.iol.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: pupilla@libero.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753928AbdBHPve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 10:51:34 -0500
In-Reply-To: <224940468.86611486549068694.JavaMail.httpd@webmail-37.iol.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "pupilla@libero.it" <pupilla@libero.it>
Date: Wed, 8 Feb 2017 11:17:48 +0100 (CET)

> Hi Folks,
> 
> After kernel update from 4.9.6 to 4.9.8, I get the below error
> message when I run this command:
> 
> root@Typhoon:~# ip route add default table 210 nexthop dev eth0 via 10.68.64.1 
> weight 1 nexthop dev eth0 via 10.68.64.2 weight 1
> RTNETLINK answers: Operation not supported
> root@Typhoon:~# uname -a
> Linux Typhoon 4.9.8 #1 SMP Tue Feb 7 17:14:54 CET 2017 x86_64 Intel(R) Core
> (TM) i5-2520M CPU @ 2.50GHz GenuineIntel GNU/Linux
> 
> Is this the expected behaviour?

David, maybe this was an unintended side effect of commit
9ed59592e3e379b2e9557dc1d9e9ec8fcbb33f16 ("lwtunnel: fix autoload of
lwt modules").
