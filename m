From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Wed, 8 Aug 2007 10:40:54 +0200
Message-ID: <200708081040.55275.mb@bu3sch.de>
References: <46B8EF13.40109@garzik.org> <20070807230458.GA9883@infradead.org> <20070807.160808.38709450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, jeff@garzik.org, mchan@broadcom.com,
	netdev@vger.kernel.org, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57476
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbXHHIlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 04:41:36 -0400
In-Reply-To: <20070807.160808.38709450.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 01:08:08 David Miller wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Wed, 8 Aug 2007 00:04:59 +0100
> 
> > Please take a look at kernel/irq/handle.c.  The irq handler is
> > always called with the right dev_id argument.  Everything would be a complete
> > nightmare to handle because you usually need to access the device private
> > data to check whether the shared irq is for this device.
> 
> Absolutely.
> 
> I can't believe we're even discussing something so obvious and
> wasting everyone's time.
> 
> 

Ok, then something "so obvious" is explained wrong in all off
the tutorials I read.
So it was _not_ that "obvious" to me. ok?

-- 
Greetings Michael.
