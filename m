From: Klavs Klavsen <kl@vsen.dk>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 16:08:19 +0200
Message-ID: <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaina.enableit.dk ([109.238.49.194]:50730 "EHLO
        kolab01.enableit.idk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750781AbdGZOIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 10:08:34 -0400
In-Reply-To: <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grabbed on both ends.

http://blog.klavsen.info/fast-retransmit-problem-junos-linux (updated to 
new dump - from client scp'ing)
http://blog.klavsen.info/fast-retransmit-problem-junos-linux-receiving-side 
(receiving host)


Eric Dumazet skrev den 2017-07-26 15:31:
> On Wed, 2017-07-26 at 14:18 +0200, Klavs Klavsen wrote:
>> the 192.168.32.44 is a Centos 7 box.
> 
> Could you grab a capture on this box, to see if the bogus packets are
> sent by it, or later mangled by a middle box ?
> 
[CUT]
> 3012336703:3012338051 is clearly outside of the window.
> Receiver claims to have received bytes that were never sent.
> 
Thank you very much..

[CUT]

-- 
Regards,
Klavs Klavsen, GSEC - kl@vsen.dk - http://blog.klavsen.info - Tlf. 
61281200

"Those who do not understand Unix are condemned to reinvent it, poorly."
   --Henry Spencer
