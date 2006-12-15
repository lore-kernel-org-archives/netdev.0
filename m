From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch 14/14] e1000: No-delay link detection at interface up
Date: Fri, 15 Dec 2006 15:37:53 +0100
Message-ID: <4582B341.8030604@linux.intel.com>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175754.3365.137.camel@laptopd505.fenrus.org> <4582B2EA.9010501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:24770 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752665AbWLOOhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 09:37:55 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4582B2EA.9010501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> ACK, though you can also just schedule the timer to run immediately, or 
> even run it yourself inside spin_lock_bh()

sure but this is very simple, clean and obvious ;)
