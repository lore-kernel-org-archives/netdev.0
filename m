From: <kernel@itris.fr>
Subject: 3c59x AUI and sockets AF_PACKET
Date: Tue, 17 Dec 2002 11:16:39 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1939.192.168.0.31.1040120199.squirrel@www.itris.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have got an important problem to solve :

When I load the 3c59x module with no option, my 2 network cards
are working well with 10baseT, and vortex-diag tells me then :
Transceiver type in use: Autonegociate.

I can open a socket with AF_PACKET level, and bind() works fine !
I can send data to the socket through RJ45.

But, when I load 3c59x with options=1, vortex-diag tells me
Transceiver type in use : AUI10baseFL.

I can configure my 2 network cards with ifconfig.

Everything is ok, but, when i want to open my socket AF_PACKET to
send data to AUI port, bind () returns -1, as though all my interfaces
are ok (ifconfig sees them all).

I would like to send data to AUI, what is the problem ?

Thanks !!

Christophe Baillon
