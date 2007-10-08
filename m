From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BNX2X RESUBMIT][PATCH 0/8] New driver for Broadcom 10Gb
 Ethernet, take two.
Date: Mon, 8 Oct 2007 14:03:01 -0700
Message-ID: <20071008140301.3e69d01d@freepuppy.rosehill>
References: <470A23E5.6030102@broadcom.com>
	<20071008102919.1cbc7983@freepuppy.rosehill>
	<1191868481.29746.27.camel@eliezer>
	<20071008120855.758d10e7@freepuppy.rosehill>
	<1191879622.5277.11.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eliezer" <eliezert@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev" <netdev@vger.kernel.org>, eilong@broadcom.com,
	vladz@broadcom.com, gertner@broadcom.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58456 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752754AbXJHVDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 17:03:36 -0400
In-Reply-To: <1191879622.5277.11.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Oct 2007 14:40:22 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> On Mon, 2007-10-08 at 12:08 -0700, Stephen Hemminger wrote:
> > On Mon, 08 Oct 2007 20:34:41 +0200
> > "Eliezer" <eliezert@broadcom.com> wrote:
> > 
> > > > * The MACRO's for 64 bit stats look like they could be done with 
> > > >   u64 and/or turned into inline's.
> > > 
> > > The MACRO's modify some of their arguments, plus they need to work on 32
> > > bit machines (are 64 bit counters always available on 32 bit machines?).
> > > so using an inline would allow the inline to be more readable but
> > > calling it would get ugly.
> > > I'm open to suggestions.
> > > 
> > 
> > u64 exists on all platforms (including 32 bit).
> > 
> 
> I think the biggest problem with these 64-bits counters (and 64-bit
> addresses) is that the hardware treats them as big endian and they get
> DMA'ed in big endian format.  We control the byte swap so that 32-bit
> quantities will have the correct endianness, but the high and low 32-bit
> words will be in the wrong spots on little endian machines.  That's why
> we need to separate the high and the low words and convert them back and
> forth.
>
There are types and tools for checking endianness see be64, etc.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
