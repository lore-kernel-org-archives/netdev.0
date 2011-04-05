From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netxen packet loss with VLANs and LRO (was: [PATCH] netxen: fix
 LRO disable warning)
Date: Tue, 5 Apr 2011 08:46:55 -0700
Message-ID: <20110405084655.10937250@nehalam>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
	<20110403190555.GA16196@torres.zugschlus.de>
	<99737F4847ED0A48AECC9F4A1974A4B80FD10E8E3C@MNEXMB2.qlogic.org>
	<20110405124158.GA28382@torres.zugschlus.de>
	<99737F4847ED0A48AECC9F4A1974A4B80FD1383943@MNEXMB2.qlogic.org>
	<20110405151854.GA32759@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33763 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab1DEPq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 11:46:57 -0400
In-Reply-To: <20110405151854.GA32759@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Apr 2011 17:18:54 +0200
Marc Haber <mh+netdev@zugschlus.de> wrote:

> On Tue, Apr 05, 2011 at 08:15:16AM -0500, Amit Salecha wrote:
> > This will fix LRO configuration problem. Do you see packet loss with
> > LRO disable ?
> 
> No, with LRO disabled things seem to be fine. LRO gets enabled by
> default though.

LRO and routing are fundamentally incompatible, that is why
the kernel attempts to turn it off. When forwarding packets
should not be combined (end-to-end principle) and that is what
LRO does.

Therefore if doing anything like bridging or forwarding kernel
attempts to get driver to turn LRO off.
