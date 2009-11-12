From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: sysfs question
Date: Thu, 12 Nov 2009 11:39:41 +0100
Message-ID: <20091112103940.GC322@e-circ.dyndns.org>
References: <200911021533.25345.matthias.fuchs@esd.eu> <20091106100427.GB323@e-circ.dyndns.org> <20091109112331.GE323@e-circ.dyndns.org> <4AF83EB7.3070401@grandegger.com> <20091112100053.GA322@e-circ.dyndns.org> <4AFBE0DD.1000408@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:17798 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbZKLKji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 05:39:38 -0500
Content-Disposition: inline
In-Reply-To: <4AFBE0DD.1000408@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Within the socketcan project, we came into a situation that
might benefit with input from the netdev mailing list.

The main issue is the policy to add sysfs properties in
/sys/class/net/canX.

The reason for this is that cards (devices) with multiple network
interfaces may require properties per network.

An obvious property would be the 'channel number of the card'. Other
properties could be things like type of output circuitry, ..., rather
hardware specific.

I see currently 3 options:
1) such properties in /sys/class/net/canX would be allowed.
2) such properties would belong in /sys/class/net/canX/<subdirectory tbd>/
3) such properties would go somewhere else.

Some input with regard to sysfs policies would be helpfull.

Kurt
