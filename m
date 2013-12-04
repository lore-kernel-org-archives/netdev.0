From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Supporting 4 way connections in LKSCTP
Date: Wed, 4 Dec 2013 16:48:16 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B745F@saturn3.aculab.com>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>	<20131127124530.GA23369@hmsreliant.think-freely.org>	<CAFXGftJQV=5Pqs3bhfiS3T1VO1q8jfaMjAUiqm2tDbtSyBCM3A@mail.gmail.com>	<529C9B50.50002@gmail.com>	<CAGugRbXFirQ5P3ek9zN86h4vvO6qsy3eNEooJOApotA+dL+C_g@mail.gmail.com>	<529CB859.9090904@gmail.com>	<CAFXGft+F52p+oaa59=5e5pGfON44N36NA-XMYi5PorzWeybnKw@mail.gmail.com>	<CAFXGft+4o6fT4SYbu3musC+-BEi=xOEGUbZSavF1-0_V1mg6zg@mail.gmail.com>	<529D3BF9.3070208@gmail.com>	<CAFXGftJtCCJ=pVxg_DH-+n2bKmoKXavog0y8mfX+h-1z3hP49Q@mail.gmail.com>	<529DCF42.1070800@gmail.com>	<CAFXGftK5tz90OzObiV7Hi+g080j3zWCNdo217CKdNkOY4JWQUg@mail.gmail.com>	<529DF73E.7060604@gmail.com> <CAFXGftKZD0zN1S=UTa_bYr71-v=7mzU=_CewTNkjPv9CGGB_Fg@mail.gmail.com> <529F395B.9040308@gmail.com> <AE90C24D6B
 3A694183C094C60CF0A2F6026B745D@saturn3.aculab.com> <529F4D1A.3050304@gmail.com> <7A4B9BD9-B2BF-4625-A2E5-500CD4A6D399@lurchi.franken.de> <529F5472.9030207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sun Paul" <paulrbk@gmail.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, "Karl Heiss" <kheiss@gmail.com>,
	"Neil Horman" <nhorman@tuxdriver.com>,
	<linux-kernel@vger.kernel.org>
To: "Vlad Yasevich" <vyasevich@gmail.com>,
	"Michael Tuexen" <Michael.Tuexen@lurchi.franken.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <529F5472.9030207@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The point is that address scoping should be used. When sending an
> INIT from 10.10.10.1 to 10.10.10.4 you should not list 192.168.1.1,
> since you are transmitting an address to a node which might or might
> not "be in the same scope".

You might have two machines that are connected via the public
internet and also via a private network.
The two sets of cabling being completely separate giving you
resilience to network failure.
In which case you definitely don't want address scoping.

While you may not want the SCTP traffic on the public network
itself, it could easily be routed separately.

We have systems that 'sort of' designate one interface for SIP/RTP
and the other for 'management'. They might run M3UA/SCTP but no one
has really thought enough about which interface(s) the M3UA traffic
should use.
(Think of an ISUP/SIP gateway using M3UA for ISUP signalling.)

	David
