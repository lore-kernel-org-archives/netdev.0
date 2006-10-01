From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: another ATM bug
Date: Sun, 1 Oct 2006 08:03:00 -0700
Message-ID: <20061001150300.GB83074@gaz.sfgoth.com>
References: <451FC3FE.8000003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gaz.sfgoth.com ([69.36.241.230]:34036 "EHLO gaz.sfgoth.com")
	by vger.kernel.org with ESMTP id S1750816AbWJAOum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 10:50:42 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <451FC3FE.8000003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc:'s trimmed again)

Jeff Garzik wrote:
> drivers/atm/ambassador.c: In function ?amb_open?:
> drivers/atm/ambassador.c:1049: warning: ?tx_rate_bits? may be used 
> uninitialized in this function
> 
> The variable is accessed before the make_rate() error code is checked, 

Or rather, the make_rate() error code isn't checked AT ALL ("error"
appears to be a write-only variable)  That seems to be the real bug

-Mitch
