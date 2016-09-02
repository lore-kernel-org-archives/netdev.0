From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 02 Sep 2016 09:37:37 -0700
Message-ID: <1472834257.5439.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
         <20160902075241.GA1814@nanopsycho>
         <1472823200.5439.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160902162513.GA1768@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33516 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932624AbcIBQhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:37:40 -0400
Received: by mail-pf0-f175.google.com with SMTP id g202so20840225pfb.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 09:37:40 -0700 (PDT)
In-Reply-To: <20160902162513.GA1768@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 18:25 +0200, Jiri Pirko wrote:

> Understand the reason. All I say is we tried hard (I surely did) in
> the past to remove bonding specific quirks and now we are adding one.
> And the simple reason is that the code is such a mess.
> 
> Just use team instead and you'll be fine. You can "google" it :)

Sure, please join _our_ team and make all the needed changes in user
land.

The kernel part of it is epsilon compared to all the control part (ie
talk to the various Google switches.), and monitoring.

I am fine to leave the bug in upstream bonding driver, if you really
want to force people out of bonding land !

Here an automated test simply used macvlan and did not remove the
macvlan before enslaving the netdev again in a bonding, we already fixed
the test, because it is faster than deploying new kernels anyway.
