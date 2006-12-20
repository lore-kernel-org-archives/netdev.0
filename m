From: Stefan Rompf <stefan@loplof.de>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 22:15:44 +0100 (MET)
Message-ID: <200612202217.31066.stefan@loplof.de>
References: <20061219185223.GA13256@srcf.ucam.org>
 <20061220152701.GA22928@dspnet.fr.eu.org>
 <1166628858.3365.1425.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Olivier Galibert <galibert@pobox.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030362AbWLTVWi@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1166628858.3365.1425.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 20. Dezember 2006 16:34 schrieb Arjan van de Ven:

> 5 seconds is unfair and unrealistic though. The *hardware* negotiation
> before link is seen can easily take upto 45 seconds already.
> That's a network topology/hardware issue (spanning tree fun) that
> software or even the hardware in your PC can do nothing about.

Spanning tree decides whether or not a port forwards traffic. It has nothing 
to do with link beat detection and autonegotation, so it shouldn't be an 
issue here.

Stefan
