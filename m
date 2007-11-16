From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Thu, 15 Nov 2007 18:17:11 -0800
Message-ID: <1195179431.5745.22.camel@dell>
References: <1194655141.5745.272.camel@teletran1>
 <20071112.212135.172019737.davem@davemloft.net>
 <1195165211.20497.107.camel@teletran1>
 <20071115.144103.24280158.davem@davemloft.net>
 <473CE526.4080209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, mcarlson@broadcom.com,
	"netdev" <netdev@vger.kernel.org>, andy@greyhouse.net
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2260 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027AbXKPB1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 20:27:31 -0500
In-Reply-To: <473CE526.4080209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-11-15 at 16:32 -0800, Rick Jones wrote:

> I'm going to get very rapidly out of my PCI depth, but on one or the 
> other (e vs X) isn't is possible from the standpoint of PCI for a device 
> to have multiple transactions outstanding at a time?

Yes, see my other response.  Multiple outstanding transactions and a
bigger maximum payload size will increase the throughput without the
need to increase the MRRS.

> 
> Does the current value of the MRRS get displayed in lspci output?  It 
> wouldn't be a slam dunk, but if someone were looking at that and saw the 
> value large they might make an educated guess.
> 

Yes:
        Capabilities: [ac] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 512 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s <1us, L1 <2us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr+ NoSnoop+
                Device: MaxPayload 256 bytes, MaxReadReq 512 bytes



