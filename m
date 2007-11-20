From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: [PATCH 0/2] netem: trace enhancement
Date: Tue, 20 Nov 2007 23:11:31 +0100
Message-ID: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:53469 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758055AbXKTWTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:19:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen

Approximately a year ago we discussed an enhancement to netem,
which we called "trace control for netem".

We obtain the value for the packet delay, drop, duplication and 
corruption from a so called "trace file". The trace file may be 
obtained by monitoring network traffic and thus enables us to emulate 
"real world" network behavior.

Traces can ether be generated individually (we supply a set of tools to 
do this) or can be downloaded from our homepage: http://tcn.hypert.net .

Since our last submission on 2006-12-15 we did some code clean up and 
have created two new patches one against kernel 2.6.23.8 and one 
against iproute2-2.6.23.
To refer to our discussion from last year please have a look at 
messages with subject "LARTC: trace control for netem".

We are looking forward for any comments, suggestions and instructions 
to bring the trace enhancement to the kernel and to iproute2.

Thanks,
Ariane


