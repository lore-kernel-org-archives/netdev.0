From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Wed, 6 Feb 2008 21:56:41 -0800
Message-ID: <200802062156.41862.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:25850 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750974AbYBGF4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 00:56:54 -0500
In-Reply-To: <47A9EA42.3080800@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 February 2008, Claudio Lanconelli wrote:
> Good idea, but with your patch applied, after some ifconfig down - 
> ifconfig up cycle, the
> enc28j60 is left in an unknown state and it doesn' Rx/Tx anything.

How long did that take?  I did about four dozen

	ifconfig eth1 up
	sleep 3
	ifconfig eth1 down

cycles ... it worked fine.  The "sleep" was to let the link
negotiation complete.

- Dave
