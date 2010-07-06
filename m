From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Tue, 06 Jul 2010 12:56:06 +0200
Message-ID: <m37hl8j2ux.fsf@ursa.amorsen.dk>
References: <4C2F7A55.5090700@redfish-solutions.com>
	<2md4g7-3s3.ln1@chipmunk.wormnet.eu>
	<4C2FC2C8.8080203@redfish-solutions.com>
	<20100703234813.GJ24655@chipmunk>
	<4C321EAF.9000508@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Clouter <alex@digriz.org.uk>, netdev@vger.kernel.org
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:55206 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063Ab0GFLLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 07:11:22 -0400
In-Reply-To: <4C321EAF.9000508@redfish-solutions.com> (Philip Prindeville's
	message of "Mon, 05 Jul 2010 12:04:31 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip Prindeville <philipp_subx@redfish-solutions.com> writes:

> Once QoS markings actually *are* implemented in carrier networks, the
> potential for abuse is non-insignificant.  Hence the suggestion to
> make it privileged.

I think you are overestimating the potential for abuse. ISP's who
oversubscribe enough to suffer from heavy congestion internally should
stop doing that and most likely have fancy congestion control equipment
installed. That equipment can apply all sorts of limits to prioritized
traffic.

For a more typical ISP, marking TCP packets with EF means you get
marginally lower and more stable latency but risk increased packet loss.
TCP does not mind a little extra latency and suffers badly from packet
loss, so that behaviour should be self-limiting.


/Benny

