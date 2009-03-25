From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-2.6 PATCH 7/10] Neterion: New driver: Main entry points
Date: Wed, 25 Mar 2009 19:47:01 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705122720@nekter>
References: <1237968795.1655.271.camel@flash> <20090325083008.0179381d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:32456 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbZCYXrG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 19:47:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090325083008.0179381d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
> > +* addr_learn_en:
> > +*	Enable Receive Traffic Steering using MAC destination address.
> > +*		0 - DISABLE
> > +*		1 - ENABLE
[Ram] I should have described this option better! This option is used in
the Xen and other virtual environments to learn the mac address of the
interface on guest OS and then programme the receive steering logic to
steer the received packets to respective VF. This is to avoid having the
nic in promiscuous mode for obvious reasons.

Ram
