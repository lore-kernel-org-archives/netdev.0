From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 01/14] Phonet global definitions
Date: Wed, 17 Sep 2008 14:05:27 +0300
Message-ID: <200809171405.27954.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-1-git-send-email-remi.denis-courmont@nokia.com> <20080917043142.GB7265@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:29682 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbYIQLFu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 07:05:50 -0400
In-Reply-To: <20080917043142.GB7265@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 September 2008 07:31:42 ext Simon Horman, you wrote:
> > +/* Phonet protocol header */
> > +struct phonethdr {
> > +	uint8_t rdev;
> > +	uint8_t sdev;
> > +	uint8_t function;
> > +	uint16_t length;
> > +	uint8_t robj;
> > +	uint8_t sobj;
> > +} __attribute__((packed));
>
> I beleive that the prefered style is to use u8 and friends for intern=
al
> kernel structures and __u8 and friends for ones that are exported to
> userspace. Ditto below.

Now, that explains things. I'll fix all of these, thanks.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
