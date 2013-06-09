From: Michael Guntsche <michael.guntsche@it-loops.com>
Subject: Fwd: [BUG] Bisected Gianfar not receiving any traffic
Date: Sun, 9 Jun 2013 22:28:51 +0200
Message-ID: <CALG0vJuENcAnrpP1Bbe2-KhV8=oazLn7pMnvC6XTNCYnAMvOhw@mail.gmail.com>
References: <CALG0vJsttWB4=fDU5yiRdf0rKgp09pY1y1jq5Ug_ra-7M7KQBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:33159 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab3FIU2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jun 2013 16:28:52 -0400
Received: by mail-ve0-f173.google.com with SMTP id jw11so4276241veb.18
        for <netdev@vger.kernel.org>; Sun, 09 Jun 2013 13:28:52 -0700 (PDT)
In-Reply-To: <CALG0vJsttWB4=fDU5yiRdf0rKgp09pY1y1jq5Ug_ra-7M7KQBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forwarded to the correct mailing list address.


---------- Forwarded message ----------
From: Michael Guntsche <michael.guntsche@it-loops.com>
Date: Sun, Jun 9, 2013 at 10:26 PM
Subject: [BUG] Bisected Gianfar not receiving any traffic
To: linux-netdev@vger.kernel.org
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>


Good evening,

While testing one of my powerpc based embedded ports I noticed that
with any 3.10-rc kernel ethernet traffic was dead on my two gianfar
NICs. The strange thing was that apparetnly outbound broadcasts seemed
to work since avahi correctly registered the name of the board. I
bisected it to the following commit.

6be5ed3fef568 gianfar: Poll only active Rx queues

Reverting this commit on 3.10-rc4 made both gianfar devices work
again. This is a rather old board so it could be that the register
that's used here is just plain wrong in my case. A few years ago I had
a similar issue where the implementation on the board here apparently
did not work correctly.

http://marc.info/?l=linux-netdev&m=131297524825104&w=2

In that case a flag was bogus as well.
If you need more information or want me to test a patch please add me
as CC since I am not subscribed to the list.

Kind regards,
Michael Guntsche
