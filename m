From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Wed, 19 Nov 2014 16:08:31 +0100
Message-ID: <20141119150831.GM16103@lunn.ch>
References: <5463B2AC.6090904@gmail.com>
 <CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
 <54650E9C.7080708@gmail.com>
 <CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
 <CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>
 <CA+KjHfY13ynH4Zr5Cerhswo3eucj3DMwq0tZ5CQquT3yuxKv-Q@mail.gmail.com>
 <20141117160934.GR2001@lunn.ch>
 <CA+KjHfauqO=BxOogexO3azW27cb1gHqEL5Mh-c+qxfUMYvf_mw@mail.gmail.com>
 <546B8E92.7080000@gmail.com>
 <CA+KjHfaHxkSY6py31ErXmerp=T68oGdz7D7pC+sXqRmkWEktcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	buytenh@wantstofly.org
To: Oliver Graute <oliver.graute@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35172 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595AbaKSPI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 10:08:58 -0500
Content-Disposition: inline
In-Reply-To: <CA+KjHfaHxkSY6py31ErXmerp=T68oGdz7D7pC+sXqRmkWEktcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 08:49:50AM +0100, Oliver Graute wrote:
> On Tue, Nov 18, 2014 at 7:23 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> > On 11/18/2014 12:30 AM, Oliver Graute wrote:
> >>> Hi Oliver
> >>>
> >>> How do you have the strapping pins on the switch set? They determine
> >>> what address on the mdio bus the chip responds to.
> >>
> >> On the circuit diagram the PIN 54  (P5_IND1/P5ID1) is set to
> >> "Configuration Address: 0101"
> >> P5_MODE[3:0]=0111 = Single RMII MAC Mode (100Mbps FD with 50 MHz clock input)
> >> PIN 59 R1_LED/NO_CPU Configuration: CPU is attached SMI address is 0x10 to 0x1F
> >>
> >> But what is the mdio address of the whole switch? or can I only
> >> address individual phy ports?
> >
> > You should specify in the Device Tree the switch pseudo-PHY address,
> > typically 16 for Marvell switches. You can still access the individual
> > ports' PHY addresses using address 0 through N.
> >
> 
> How do I do that exactly? do you have an example Device Tree Snippet?

Here is an example for a Dlink DIR665.

http://www.spinics.net/lists/arm-kernel/msg374004.html

you need to modify this line:

reg = <0 0>;	/* MDIO address 0, switch 0 in tree */

Change the first 0 to 0x10.

       Andrew
