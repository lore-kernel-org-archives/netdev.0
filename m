From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/7] chelsio: use netdev_priv
Date: Wed, 6 Dec 2006 01:51:29 +0100
Message-ID: <20061206005129.GA3610@electric-eye.fr.zoreil.com>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com> <20061206001652.GD2377@electric-eye.fr.zoreil.com> <20061205163921.61ea21e6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32779 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758903AbWLFAxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:53:05 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061205163921.61ea21e6@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> NAK for this driver. dev->priv points to a different location for each port on
> dual port board.  To use netdev_priv() requires more serious surgery..Q

Ok, it's removed from the branch. Patch #6 has been modified.

Should I wait for someone to pick-up #1..#3 before resending #5..#7 ?

-- 
Ueimor
