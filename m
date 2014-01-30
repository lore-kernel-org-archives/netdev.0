From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 16:42:30 -0500
Message-ID: <52EAC746.1030102@pobox.com>
References: <20140130211816.GB3787@xanatos> <52EAC696.6050708@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:42294 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbaA3Vmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 16:42:32 -0500
In-Reply-To: <52EAC696.6050708@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sarah, on a related note:

Is there a parameter or knob of some kind to tell the XHCI driver
to treat a specific port as USB2 (480mbit/sec max) rather than USB3 ?

The Dell XPS-13 Ultrabooks all suffer from some kind of flaw, whereby the left side
USB3 port is unreliable at SuperSpeed; the right side port works flawlessly.
The MS-Windows driver has a workaround of some sort, but we don't.

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
