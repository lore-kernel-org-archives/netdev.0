From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: [RFC] ipmr: About origin IP address of flow in multicast routing API
Date: Wed, 5 Jan 2011 04:59:07 -0800 (PST)
Message-ID: <208282.77453.qm@web62507.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web62507.mail.re1.yahoo.com ([69.147.75.99]:42105 "HELO
	web62507.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751810Ab1AEM7J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 07:59:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Context: IGMP Proxying.

For using multicast routing API with setsockopt and MRT_ADD_MFC, we need to set the mfcc_origin in a struct mfcctl.

Is there a way to use a wildcard for mfcc_origin to say "any origin" IP address, by example 0.0.0.0 ?

Thus we could add a MFC with only the multicast group and the mfcc_parent, reading a SOCK_RAW/IPPROTO_IGMP socket, without the need to listen the multicast flow to find the origin IP.

Any thought ?

Francois-Xavier Le Bail



      
