From: Christoph Lameter <cl@linux-foundation.org>
Subject: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 11:13:55 -0600 (CST)
Message-ID: <alpine.DEB.2.00.0911301104520.16713@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:35470 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbZK3RNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:13:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that the current sip nat module in the kernel has only limited
functionality. According to

http://people.netfilter.org/chentschel/docs/sip-conntrack-nat.html

one has to point the firewall at the target host for the SIP proxying to
work. Therefore the kernel will only support a single inside phone
connecting via SIP to the outside. For a network that has a series of
phones inside the NAT zones this means that the firewall sip nat is not
useful.

siproxd http://siproxd.sourceforge.net/ seems to be able to handle
multiple outgoing SIP connections but one needs to specify an outbound
proxy for each inside SIP phone.

Isnt there a way to make the kernel module work in the same way siproxd
works and able to support multiple phones? Right now configuring SIP
connectivity is a messy thing that is not easily setup. Can we fix this?


