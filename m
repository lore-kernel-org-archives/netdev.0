From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next v2 08/15] ixgbevf: compare total_rx_packets and
 budget in ixgbevf_clean_rx_irq
Date: Fri, 21 Nov 2014 11:07:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F648C@AcuExch.aculab.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416524953-15161-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Emil Tantilov <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33477 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753877AbaKULIm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 06:08:42 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14715-06 for <netdev@vger.kernel.org>;
 Fri, 21 Nov 2014 11:08:31 +0000 (GMT)
In-Reply-To: <1416524953-15161-9-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> total_rx_packets is the number of packets we had cleaned, and budget is
> the total number of packets that we could clean per poll. Instead of
> altering both of these values we can save ourselves one write to memory by
> just comparing total_rx_packets to the budget and as long as we are less
> than budget we continue cleaning.
> 
> Also change the do{}while logic to while{} in order to avoid processing
> packets when budget is 0.

Does it matter if one packet is processed when budget is zero?
The 'do {} while ();' version will generate better code.

	David
 
