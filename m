From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3c59x AUI and sockets AF_PACKET
Date: Tue, 17 Dec 2002 12:10:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DFF84C2.9090305@candelatech.com>
References: <1939.192.168.0.31.1040120199.squirrel@www.itris.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kernel@itris.fr
In-Reply-To: <1939.192.168.0.31.1040120199.squirrel@www.itris.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kernel@itris.fr wrote:
> Hi,
> 
> I have got an important problem to solve :
> 
> When I load the 3c59x module with no option, my 2 network cards
> are working well with 10baseT, and vortex-diag tells me then :
> Transceiver type in use: Autonegociate.
> 
> I can open a socket with AF_PACKET level, and bind() works fine !
> I can send data to the socket through RJ45.
> 
> But, when I load 3c59x with options=1, vortex-diag tells me
> Transceiver type in use : AUI10baseFL.
> 
> I can configure my 2 network cards with ifconfig.
> 
> Everything is ok, but, when i want to open my socket AF_PACKET to
> send data to AUI port, bind () returns -1, as though all my interfaces
> are ok (ifconfig sees them all).

After the call fails, do this (it may offer a clue):

printf("%i:  %s\n", errno, strerror(errno));
/* Hopes syntax is correct */

> 
> I would like to send data to AUI, what is the problem ?
> 
> Thanks !!
> 
> Christophe Baillon
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
