From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: g3 + HP iLO2 -> IPv6 broken
Date: Wed, 8 Oct 2008 14:10:08 -0700
Message-ID: <20081008211008.GA28179@xw6200.broadcom.net>
References: <gbu10u$uvr$1@ger.gmane.org>
 <20080930225334.GA735@xw6200.broadcom.net>
 <20080930233042.GB18447@pest>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bernhard Schmidt" <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1805 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754335AbYJHVKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:10:20 -0400
In-Reply-To: <20080930233042.GB18447@pest>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 04:30:42PM -0700, Bernhard Schmidt wrote:
> On Tue, Sep 30, 2008 at 03:53:34PM -0700, Matt Carlson wrote:
> 
> > It sounds like the iLO2 firmware is messing around with the rx filter.
> > I've heard of problems like this before with another management agent.
> >
> > Can you give me the output to 'ethtool -i <device>' and the iLO2
> > firmware version?
> 
> svr01:~# ethtool -i eth0
> driver: tg3
> version: 3.94
> firmware-version: 5715-v3.28, UMP 1.15
> bus-info: 0000:03:04.0
> 
> iLO 2 Standard 1.60 at 16:05:58 Jul 11 2008
> Server Name: DL320G5P0200
> Server Power: On

Bernhard, out of curiosity, are VLANs involved in this problem?


