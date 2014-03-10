From: "Soum, Redouane" <redouane.soum@intel.com>
Subject: TCP reordering and Multiple DL path
Date: Mon, 10 Mar 2014 15:44:04 +0000
Message-ID: <AB9D0874A51C404B8D86602911E629521A9E0D4D@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44474 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277AbaCJPoH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 11:44:07 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have several path in DL between an Application Processor and a Modem using different network interfaces (USB CDC NCMs) with the same ip address (connected to the same network)

Having several network interfaces used in DL implies to have out of order packets, even if the ooo packets will most likely come close together.

Here is my understanding on the impact on TCP throughput :

-        OOO packets will lead to Dup acks.
-        When sender receives 3 Dup acks it'll start fast recovery which will reduce TCP congestion window.

First question is my understanding correct ?

Assuming it is : 
In order to solve that issue I am thinking to add a small delay before sending dup acks for OoO packets.
The objective is to be sure that dup acks for OoO packets will only be sent for OoO packet due to different path in the network, and not because of the different network interfaces.

However I am not sure how complex it would be to implement and which part of the TCP stack need to be modified.
Any advice to solve that issue ?

Thx
--Red1

---------------------------------------------------------------------
Intel Corporation SAS (French simplified joint stock company)
Registered headquarters: "Les Montalets"- 2, rue de Paris, 
92196 Meudon Cedex, France
Registration Number:  302 456 199 R.C.S. NANTERRE
Capital: 4,572,000 Euros

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
