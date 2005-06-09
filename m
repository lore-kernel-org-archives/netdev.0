From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Wed, 8 Jun 2005 21:30:27 -0700
Message-ID: <200506090430.j594USVG002685@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 FYI, looks like the code in the nine patches is not responsible for the
performance drop; the problem is elsewhere in the Super TSO code.

-----Original Message-----
From: kshaw [mailto:kim.shaw@neterion.com] 
Sent: Wednesday, June 08, 2005 8:34 PM
To: 'David S. Miller'
Cc: ravinandan.arakali@neterion.com; leonid.grossman@neterion.com
Subject: RE: test Super TSO

David,

I have applied all 9 patches (6-9 are done by editing source files), I don't
see Tx performance drop from any patch, Tx throughput remains at 6.17 Gb/s -
6.18 Gb/s.

The following is configuration:
4 way Opteron system .247 with shipping kernel 2.6.12-rc5 as TX system ,
4 way Opteron system .226 with kernel 2.6.11.5 as Rx system, NIC driver
REL_1-7-7-7_LX installed on both systems, Mtu is set to 9000 on both
systems.
Systems are connected back to back.
Run 8 nttcp connections from Tx system to Rx system for 60 seconds.
TSO is set to default on in both systems.


I also re-tested the original TSO patch which I used weeks ago,
With above same hardware, kernel 2.6.12-rc4 applied with original TSO patch
on Tx System, Tx throughput drops to 5.28 Gb/s.
