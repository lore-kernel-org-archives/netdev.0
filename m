From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [Prism54-devel] GUPD (Grand Unified Prism54 Driver) Open discussion
Date: Wed, 16 Jun 2004 09:37:50 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406160937.50943.vda@port.imtp.ilyichevsk.odessa.ua>
References: <5.1.0.14.2.20040615143603.02a40b48@pop.t-online.de> <20040616001111.GK6253@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez),
        Margit Schubert-While <margitsw@t-online.de>
In-Reply-To: <20040616001111.GK6253@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> * WDS - Umm someone on the list had mentioned they had used WDS
>   successfully and had some patches (?) Are you still alive? Are you
>   still working on this?

No promises, but I'd like to take a look at WDS,
since I just got another prism54.

There is one problem - I don't know what WDS is
supposed to do, because I use WDS link with hostap driver
in a awkward way - I *turn off* AP bridging.
This turns AP into kind of multihomed pseudo ethernet
device which does NOT automatically forward packets
from one STA to another (it is done via normal IP routing
instead). In this setup, logically WDSes are just another
devices, distinct from AP:

+--------------+        +AP-+
|  core kernel |<-------| < | <--------- STA1
|(does routing)|------->| > | ---------> STA2
|              |        +---+
|              |        +WDS+
|              |<------>|<->| <--------> WDS peer
+--------------+        +---+

I suspect that most other people do not disable bridging.
For them WDS cannot be a separate device... or what?
I'm lost here.

Let's imagine three APs linked with WDS (double links
in a picture below):

sta1 <---> AP1 <===> AP2 <===> AP3 <---> sta2

Say, sta1 wants to sent a packet to sta2.
What should happen?
--
vda
