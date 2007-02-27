From: Jeff Garzik <jeff@garzik.org>
Subject: Re: natsemi: Fix detection of vanilla natsemi cards
Date: Tue, 27 Feb 2007 04:31:07 -0500
Message-ID: <45E3FA5B.8040306@garzik.org>
References: <20070225153726.GB15068@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	Tim Hockin <thockin@hockin.org>,
	Jeff Garzik <jgarzik@pobox.com>, Adrian Bunk <bunk@stusta.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47587 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161098AbXB0Jbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:31:42 -0500
In-Reply-To: <20070225153726.GB15068@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> Bob Tracy <rct@gherkin.frus.com> reported that the addition of support
> for Aculab E1/T1 cPCI carrier cards broke detection of vanilla natsemi
> cards.  This patch fixes that: the problem is that the driver-specific
> ta in the PCI device table is an index into a second table and this
> had not been updated for the vanilla cards.
> 
> This patch fixes the problem minimally.
> 
> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

applied


