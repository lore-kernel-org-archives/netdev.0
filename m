From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Thu, 21 Aug 2008 09:21:28 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242024953CE46@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20080821160928.GB21967@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "'Marc Haber'" <mh+linux-kernel@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3885 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbYHUQVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 12:21:35 -0400
In-Reply-To: <20080821160928.GB21967@torres.zugschlus.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Haber wrote:

> On Wed, Aug 20, 2008 at 07:11:50AM -0700, Michael Chan wrote:
> > On Wed, 2008-08-20 at 10:47 -0700, Marc Haber wrote:
> > > Now I need to understand why the other, nearly[1]
> identical box didn't
> > > need the patch to function properly.
> >
> > It depends on whether you have ASF enabled or not and what
> version of
> > ASF you have.  ASF is management firmware running inside
> the NIC.  When
> > the tg3 driver loads, it will show ASF[1] in dmesg if ASF
> is enabled.
>
> Both machines have that string in their dmesg.
>

It may be different versions of ASF.  Try ethtool -i eth0.  It
may tell us the firmware version.

