From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 08:48:34 +0200 (EET)
Message-ID: <Pine.LNX.4.62.0503100843280.15067@webhosting.rdsbv.ro>
References: <B8561865DB141248943E2376D0E85215FFE1C8@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: hadi@cyberus.ca, Henrik Nordstrom <hno@marasystems.com>,
	Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <B8561865DB141248943E2376D0E85215FFE1C8@DHOST001-17.DEX001.intermedia.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 1st bug:  Customer had the same 10.100.xx.xx/24 net that I had and my
> inter-system communication wouldn't work, because all my routes got
> screwed up.  (i.e the SNMP sub-agents couldn't talk with the master).
>
> 1st response to bug:  Well can you use another network address range?
> Customer response:  Hell no.
>
> Solution to bug1:  Easy, let the user configure the mgmt network ip
> address.
> Customers answer to bug1 solution:  Get the hell out of here; you don't
> do out-of-band mgmt.  Do you know what a security risk this is for me?
> Blah blah blah....  Even though all inter-chassis communication was done
> securely, I couldn't convince them. I had a customer boot me out of his
> office and boot our company out **because** of my design.  Not a good
> feeling.

You say that a client will not allow you to use net 10.
OK, but, the same client would not allow you to use 127/8 because they use 
it!
What I'm saying is that 10.0.0.0/8 and 127.0.0.0/8 are the same. The 
customer can use them.
You assume that the client will not use 127/8. Why? This is wrong.
You can use it, the client can use it.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
