From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: [PATCH 2/4] ipgre: follow state of lower device
Date: Fri, 4 May 2012 18:34:39 -0500
Message-ID: <184D23435BECB444AB6B9D4630C8EC8303E7C50F@XMB-RCD-303.cisco.com>
References: <20120412163115.076119065@vyatta.com><20120412163142.544953001@vyatta.com><20120414.145302.154475725141872738.davem@davemloft.net> <20120503154025.0845359e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <kaber@trash.net>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-7.cisco.com ([173.37.86.78]:19539 "EHLO
	rcdn-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756361Ab2EDXel convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 19:34:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20120503154025.0845359e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this the same issue I described in the email below?

  Subject:Route flush on linkdown: physical vs virtual/stacked
interfaces
  http://marc.info/?l=linux-netdev&m=133468470719285&w=2

(ie, need to propagate carrier changes to upper layer device/s)

Thanks
/Chris

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org] On Behalf Of Stephen
> Hemminger
> Sent: Thursday, May 03, 2012 3:40 PM
> To: David Miller
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 2/4] ipgre: follow state of lower device
> 
> On Sat, 14 Apr 2012 14:53:02 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 12 Apr 2012 09:31:17 -0700
> >
> > > GRE tunnels like other layered devices should propogate
> > > carrier and RFC2863 state from lower device to tunnel.
> > >
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > Like others I don't like the ugly hash traversal.
> >
> > A small hash on ifindex, iflink, or whatever ought to be easy and
make
> > the code look much nicer.
> >
> > Longer term project is that a lot of this tunneling code can be
> > commonized at some point.
> 
> The whole set of tunnels needs to be cleaned up to be something
modular, clean
> and cached like the code in OpenVswitch.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
