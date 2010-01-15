From: Christian Durieux <christian_durieux@hotmail.com>
Subject: looking for veth like.
Date: Fri, 15 Jan 2010 11:55:03 +0000
Message-ID: <SNT109-W51E286B7253382E982C28F83690@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt0-omc1-s36.snt0.hotmail.com ([65.55.90.47]:28475 "EHLO
	snt0-omc1-s36.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757115Ab0AOMBV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 07:01:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
I need to inter-connect two bridges together.
I want to get this:


----------------=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ------=
------------


|=A0=A0=A0=A0=A0=A0 br0 =A0=A0=A0 |=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 |=A0=A0=A0=A0=A0=A0=A0=A0 br1=A0=A0=A0=A0=A0 |


----------------=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ------=
------------


=A0=A0 (veth0) ^=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ^ (=
veth1)


=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 |___________|

So with my current kernel release (2.6.28-17), I used the virtual Ether=
net pair device (veth) kernel module associated to the IP utility.

I did it as follows:

# First bridge
brclr addbr br0
ifconfig br0 up

# Second bridge
brctl addbr br1
ifconfig br1 up

# veth link
ip link add name veth0 type veth peer name veth1
ifconfig veth0 up
ifconfig veth1 up

# insertion
brctl addif br0 veth0
brctl addif br1 veth1

And for such kernel release it works fine.

But now I want to do so with an oldest kernel release (2.6.18-8 for ins=
tance).
This old release do not provide the virtual Ethernet pair device module=
=2E

Is there a way to=A0 do the same with that oldest kernel release ?=20
It there an veth-like module ? (I saw some stuffs suche as etun but can=
 not get it... ?)

Thanks,
Christian.
 		 	   		 =20
_________________________________________________________________
Discutez en direct avec vos amis sur Messenger !
http://www.windowslive.fr/messenger