From: folkert <folkert@vanheusden.com>
Subject: AX.25
Date: Thu, 13 Feb 2014 22:08:37 +0100
Message-ID: <20140213210837.GO30054@belle.intranet.vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from keetweej.vanheusden.com ([80.101.105.103]:21231 "EHLO
	keetweej.vanheusden.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbaBMVQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 16:16:43 -0500
Received: from belle.intranet.vanheusden.com (unknown [192.168.64.100])
	by keetweej.vanheusden.com (Postfix) with ESMTP id 152D61611FE
	for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 22:08:38 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In my neighbourhood (the Netherlands) I'm trying to make people
enthousiast again for packet radio (AX.25) over CB radio (27mc).

For that I'm setting up a couple of nodes spread out of the netherlands
which I want to interconnect over the internet (untill there is enough
coverage).
Each node has a radio and a pc with a baycom- or soundmodem setup (and
maybe in the future these nice tnc-pi devices).

I've been investigating how to do this. For the distribution over the
internet there's ax25ipd. Documention is a bit sparse though. Also I
could not find how to bridge the ax.25 device of the baycom/sound-modem
and the network device brought up by ax25ipd. It does mention bpqether
module but from the name (and the modinfo output) I concluded that it is
for bridging over ethernet, so not for bridging between two ax.25
devices. Also I did not find anything like "ax25_forward" or so
underneath /proc (like the /proc/sys/net/ipv4/ip_forward we have for
ipv4).
I think I read something about interfacing to TNC devices directly by
ax25ipd but that won't work with baycom- and soundmodems.

I'm capable of developing my own software, I wrote a network sniffer
(in "sysopview") and stuff that creates raw-packets for IP, so how
difficult can ax.25 be?
	My plan is: using pcap sniff each packet from the two network
devices and then using raw sockets feed them to the opposite interface.
Yeah or I could create my own ax25ipd alike program, that does not
matter.
	My question is: apart from the design, is this the way to go?
Should I indeed inject packets using raw ax25 sockets and retrieve them
using pcap? Or also retrieve them using raw sockets? Or is there maybe
even ready-made solution that I overlooked during the lengthy google
search?


regards,

Folkert van Heusden

-- 
MultiTail is a versatile tool for watching logfiles and output of
commands. Filtering, coloring, merging, diff-view, etc.
http://www.vanheusden.com/multitail/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
