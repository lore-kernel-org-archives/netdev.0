From: "David S. Miller" <davem@redhat.com>
Subject: Re: PROBLEM: udp not delivered on special socket receive buffer
 size
Date: Wed, 10 Jul 2002 19:15:35 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020710.191535.28787427.davem@redhat.com>
References: <200207100945.13002.welk@fokus.gmd.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
   gober@fokus.gmd.de
Return-path: <owner-netdev@oss.sgi.com>
To: welk@fokus.gmd.de
In-Reply-To: <200207100945.13002.welk@fokus.gmd.de>
List-Id: netdev.vger.kernel.org

   From: Matthias Welk <welk@fokus.gmd.de>
   Date: Wed, 10 Jul 2002 09:45:11 +0200

   So my question is:
   
   Is this a bug or are there any reasons for this magic 831 bytes
   barrier ?

Assuming anything about the meaning of the send/receive buffer sizes,
as raw numbers, is going to cause no ends of problems for any
application.

Under Linux, the size of the socket buffer structure itself (not just
the data) is subtracted from the socket buffer size when accounting.
That is a perfectly legal thing to do.  So the Java code is broken.
