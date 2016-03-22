From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling
 fib_lookup()
Date: Tue, 22 Mar 2016 13:15:51 -0700
Message-ID: <1458677751.10868.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458673017-3528-1-git-send-email-lrichard@redhat.com>
	 <56F19660.4040502@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lance Richardson <lrichard@redhat.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34227 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbcCVUPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 16:15:53 -0400
Received: by mail-pf0-f177.google.com with SMTP id x3so324769152pfb.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 13:15:53 -0700 (PDT)
In-Reply-To: <56F19660.4040502@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-22 at 13:00 -0600, David Ahern wrote:
> On 3/22/16 12:56 PM, Lance Richardson wrote:

> >
> > Fixes: 58189ca7b2741 ("net: Fix vti use case with oif in dst lookups")

> DaveM: this should go into stable releases back to v4.3.
> 

The 'Fixes' tag tells this already ;)

$ git describe --contains 58189ca7b2741
v4.3-rc3~13^2~63
