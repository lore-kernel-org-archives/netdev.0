From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 02/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 11:32:49 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF9@XCH-NW-7V2.nw.nos.boeing.com>
References: <200711071658.59478.netdev@axxeo.de><20071108.031214.124029872.yoshfuji@linux-ipv6.org><39C363776A4E8C4A94691D2BD9D1C9A1029EDBF2@XCH-NW-7V2.nw.nos.boeing.com> <20071108.034840.124896893.yoshfuji@linux-ipv6.org> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com> <47320B9B.6050301@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, <netdev@axxeo.de>,
	<netdev@vger.kernel.org>
To: "Simon Arlott" <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:35291 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbXKGTdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 14:33:36 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47320B9B.6050301@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Simon Arlott [mailto:simon@fire.lp0.eu] 
> Sent: Wednesday, November 07, 2007 11:02 AM
> To: Templin, Fred L
> Cc: YOSHIFUJI Hideaki / 吉藤英明; netdev@axxeo.de; netdev@vger.kernel.org
> Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
> 
> On 07/11/07 18:52, Templin, Fred L wrote:
> >> > > > > +	eui[0] = 0;
> >> > > > > +
> >> > > > > +	/* Check for RFC3330 global address ranges */
> >> > > > > +	if (((ipv4 >= 0x01000000) && (ipv4 < 0x0a000000)) ||
> >> > > > > +	    ((ipv4 >= 0x0b000000) && (ipv4 < 0x7f000000)) ||
> >> > > > > +	    ((ipv4 >= 0x80000000) && (ipv4 < 0xa9fe0000)) ||
> >> > > > > +	    ((ipv4 >= 0xa9ff0000) && (ipv4 < 0xac100000)) ||
> >> > > > > +	    ((ipv4 >= 0xac200000) && (ipv4 < 0xc0a80000)) ||
> >> > > > > +	    ((ipv4 >= 0xc0a90000) && (ipv4 < 0xc6120000)) ||
> >> > > > > +	    ((ipv4 >= 0xc6140000) && (ipv4 < 
> >> 0xe0000000))) eui[0] |=
> >> > > > > 0x2;
> >> I don't understand.
> >> 
> >> For example, 1.0.0.11 is valid IPv4 global address.
> >> In little-endian, this is not in the range of
> >> 0x00000001 <= addr <= 0x0000000a (addr is 0x0b000001).
> > 
> > Maybe it is I who did not understand. Can you suggest a 
> clean solution?
> 
> ((ipv4 & htonl(0xFF000000)) == htonl(0x0A000000)) etc.?

I'm not sure this works when we consider disjoint ranges
of globally-unique IP prefixes. Do you have a vision for
how the entire conditional would look like?

Thanks - Fred
fred.l.templin@boeing.com

> Simon Arlott
