From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 09:44:26 -0800
Message-ID: <1447955066.22599.235.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119.113336.1788979303067913870.davem@davemloft.net>
	 <1447951664.22599.230.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119.120259.878540767821437922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, lorenzo@google.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	dtor@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33057 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbKSRo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:44:29 -0500
Received: by pabfh17 with SMTP id fh17so90420612pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 09:44:29 -0800 (PST)
In-Reply-To: <20151119.120259.878540767821437922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 12:02 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 19 Nov 2015 08:47:44 -0800
> 
> > So if the reaction of this is "Patch is coming from Android, must be
> > yet another hack", it is quite not fair.
> 
> I have not said this.
> 
> But the attitude of that all of a sudden we must care urgently about
> some Android issue they have waited as long as possible to address
> upstream... that stinks.
> 
> How come our opinions and ideas about how to approach solving this
> problem were not of any value two years ago?  Why?
> 
> We've waited two years, surely Android folks can wait however long it
> takes to discuss this design and alternative approaches.


Then we are in perfect agreement.

I did not say there was a sudden urgency, sorry for the
misunderstanding.
 I only know that TCP listener rewrite in 4.4 will again trigger all
these pesky Android bugs, I would like avoiding the mess I had to cope
when TIME_WAIT were merged into regular ehash established chains.

This is the major reason I worked closely with Lorenzo.

Thanks.
