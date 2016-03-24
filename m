From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: ipv4: Multipath needs to handle unreachable
 nexthops
Date: Thu, 24 Mar 2016 10:55:24 -0700
Message-ID: <1458842124.12033.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com>
	 <1458837934.12033.6.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56F4274C.70707@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33620 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbcCXRz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 13:55:26 -0400
Received: by mail-pf0-f176.google.com with SMTP id 4so63972263pfd.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:55:26 -0700 (PDT)
In-Reply-To: <56F4274C.70707@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 11:43 -0600, David Ahern wrote:
> On 3/24/16 10:45 AM, Eric Dumazet wrote:
> > On Thu, 2016-03-24 at 08:25 -0700, David Ahern wrote:
> >> Multipath route lookups should consider knowledge about next hops and not
> >> select a hop that is known to be failed.
> >
> > Does not look a net candidate to me.
> 
> you don't consider this a bug? certainly not a feature.

For a bug that lasted years, certainly the fix can be properly tested in
net-next, then eventually backported to stable once validated.

Unless there is a sudden concern about known ways to crash linux
hosts ;)
