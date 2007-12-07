From: Ben Dooks <ben@fluff.org>
Subject: Re: [patch 07/22] NET: DM9000: Use msleep() instead of udelay()
Date: Fri, 7 Dec 2007 15:42:19 +0000
Message-ID: <20071207154219.GG3244@fluff.org.uk>
References: <20071119203910.687238131@fluff.org> <20071119204013.911269341@fluff.org> <474780E1.2020700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	vince@simtec.co.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:56316 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752702AbXLGPmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 10:42:43 -0500
Content-Disposition: inline
In-Reply-To: <474780E1.2020700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 23, 2007 at 08:39:45PM -0500, Jeff Garzik wrote:
> are you sure you cannot sleep during suspend?

Yes. This is not the first driver that has had this problem,
see the sm501 as another example.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
