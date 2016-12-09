From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Thu, 08 Dec 2016 16:30:32 -0800
Message-ID: <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
         <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
         <1481233016.11849.1@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36799 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753870AbcLIAbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 19:31:34 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so297647pgx.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 16:31:34 -0800 (PST)
In-Reply-To: <1481233016.11849.1@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 16:36 -0500, Josef Bacik wrote:

> We can reproduce the problem at will, still trying to run down the 
> problem.  I'll try and find one of the boxes that dumped a core and get 
> a bt of everybody.  Thanks,

OK, sounds good.

I had a look and :
- could not spot a fix that came after 4.6. 
- could not spot an obvious bug.

Anything special in the program triggering the issue ?
SO_REUSEPORT and/or special socket options ?

Thanks.
