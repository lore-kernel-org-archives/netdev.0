From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH] dp83640: Fix NOHZ local_softirq_pending 08 warning
Date: Thu, 12 Jan 2012 12:56:25 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3013A992029@alice.at.omicron.at>
References: <1326189135-27770-1-git-send-email-manfred.rudigier@omicron.at>
 <20120111190300.GA14376@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:37447 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481Ab2ALL4o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 06:56:44 -0500
In-Reply-To: <20120111190300.GA14376@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran [mailto:richardcochran@gmail.com]
Sent: Wednesday, January 11, 2012 20:03

>> fix replaces netif_rx() with netif_rx_ni() which has to be used from
>> process/softirq context.
>
>Thanks for spotting this. Can you post this once again with a Cc tag for the
>stable branch, too?
>
>Thanks,
>Richard

Okay.

Manfred
