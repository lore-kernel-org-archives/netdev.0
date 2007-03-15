From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/3] natsemi: Consistently use interrupt enable/disable
 functions
Date: Thu, 15 Mar 2007 11:00:20 -0400
Message-ID: <45F95F84.8030308@garzik.org>
References: <20070314194912.414925000@sirena.org.uk> <20070314195156.690711000@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: broonie@sirena.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50151 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030369AbXCOPA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:00:27 -0400
In-Reply-To: <20070314195156.690711000@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

broonie@sirena.org.uk wrote:
> The natsemi drivers include functions for enabling and disabling
> interrupts from the chip but these are not used in all code paths.  This
> patch changes the code paths that touch the interrupt enable register to
> use the functions.  In all cases this adds an extra PCI read to post the
> operation but since none of these are in fast paths this shouldn't be
> too much of a problem.
> 
> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

applied 1-3 to #upstream-fixes


