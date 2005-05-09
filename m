From: "'Jeff' R. Steinhagen" <Jeff@steinhagen.ch>
Subject: forcing a packet to go through hw net device
Date: Mon, 09 May 2005 14:58:42 +0200
Message-ID: <200505091458.42118.Jeff@steinhagen.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I have a (maybe trivial) question about the kernel's networking code:

A packet with an "outside" destination goes through all layers including the 
hardware interface (user->socket->protocol->IP->HW). However if the packet is 
addressed to a local IP the transport through and checks by the hardware 
layer are avoided. This is perfectly OK for "normal" network usage.

I am profiling some network hardware and related code. Is it possible to force 
an internally generated packet to be send through all/the hardware layers?

Thanks for your help!

Cheers,
Jeff
