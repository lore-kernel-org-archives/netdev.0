From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: TCP hardware assists
Date: Fri, 13 Aug 2004 21:27:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408140426.i7E4QVx0006252@guinness.s2io.com>
References: <001401c48194$62497260$9610100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <001401c48194$62497260$9610100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,
Apologies for the wide distribution, hopefully this is the right forum...

We are finalizing design for the next version of our 10GbE ASIC; in a
nutshell the device supports both TOE/RDMA interface as well as standard
Ethernet interface with number of "Stateless" TCP assists like TSO, offload
for large UDP segments, etc. (The non-offload path will be software
compatible with the current Xframe 10GbE NIC).

We are going to further enhance the latter "partial offload" (aka "stateless
offload", aka "fast path acceleration" :-)) interface by adding some
additional features. 

As an example, some time ago Andi put forward an idea of socket demultiplex
in hardware, to improve receive side performance.
This is already being designed in, and we are willing to consider other TCP
hardware assists as well.

I'm looking for volunteers who would collaborate with us on this project and
implement kernel support for the socket demultiplex (and possibly other
assists), with S2io providing the necessary driver support and access to the
(likely, remote) 10GbE hardware platform.

Most if not all the work could be done on a current S2io 10GbE hardware;
main limitation for now will be the number of sockets since shipping NIC has
only 8 independent rx hw queues but the next version will support tens of
thousands. 

Please contact me if there is an interest in the project. I'm not sure about
the legal framework yet, access to our hw specs may require an NDA but the
driver code will be released under GPL of course, much like the current S2io
Linux driver.

Regards, Leonid

Leonid Grossman
Software Development
www.s2io.com
