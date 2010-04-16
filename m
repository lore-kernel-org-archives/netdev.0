From: "George B." <georgeb@gmail.com>
Subject: Re: Network multiqueue question
Date: Thu, 15 Apr 2010 21:00:48 -0700
Message-ID: <j2gb65cae941004152100je5a3c3c9lba9e96ecb95bf04c@mail.gmail.com>
References: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
	 <1271353637.16881.2846.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:62336 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab0DPEAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 00:00:48 -0400
Received: by pzk42 with SMTP id 42so1682765pzk.4
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 21:00:48 -0700 (PDT)
In-Reply-To: <1271353637.16881.2846.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 10:47 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:



> Since this bothers me a bit, I will probably work on this in a near
> future. (adding real multiqueue capability and RCU to bonding fast
> paths)
>
> Ref: http://permalink.gmane.org/gmane.linux.network/152987

That would be great and you would have my sincere thanks..  And if
anyone is interested, what we do is take a pair of "top of rack"
switches and cluster them together so they appear as one switch.
Configure a LAG consisting of a port on each physical switch to a pair
of bonded interfaces on the server and use mode 2 bonding.  In normal
operation, both interfaces are active.  Should one switch experience a
power or interface failure, the server sees one of the interfaces fail
but just keeps working on the remaining interface.  There is no
"failover" event going on.

Thanks,

George
