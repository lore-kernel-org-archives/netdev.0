From: "Steve Iribarne" <steve.iribarne@dilithiumnetworks.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Tue, 8 Mar 2005 07:07:42 -0800
Message-ID: <B8561865DB141248943E2376D0E85215FFDF5B@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Eran Mann" <emann@mrv.com>, "Zdenek Radouch" <zdenek@rcn.com>,
	"Thomas Graf" <tgraf@suug.ch>, "Andi Kleen" <ak@muc.de>,
	"Martin Mares" <mj@ucw.cz>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-> BTW, please cc netdev or myself if you are addressing me. This email
was
-> just forwarde by someone else to me - I am not on linux-net. You seem
to
-> have trimmed down the CC list.
-> 

You should join the list and the quit when you are done.  Otherwise,
like with this email I get multiple copies of it.

-> I read this a few times and still didnt get it:
-> Why is it that people using 1918 addresses are affecting you?
-> Does using 127.x help you because you assume _nobody_ else would be
using
-> 127.x addresses?

I am in a chassis.  I need a way to do interface card communication.
Even if those cards are exposed to the outside world.  

-> I am assuming you want this address for some internal network whereas
the
-> external contains some routable addresses?
->

Yep.

-> > So I have this working in my products now.  I had to do something a
bit
-> > different in that I want a "special" 127.xx.xx.xx range to be sent
out
-> > on the wire.  So here is what I did.
-> 
-> [..]
-> 
-> Seems you did too much. Look at the 2 liner patch posted by Eran Mann

Right. That works too.  But what I did was about 10 lines of code.  And
I refined it a bit better I believe.  That way packets destined for "my"
internal network got out the appropriate interface.  The rest go on
their merry way to the loopback world.



