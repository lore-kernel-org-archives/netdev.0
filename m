From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8136
Date: Fri, 25 Aug 2006 21:04:55 +0200
Message-ID: <20060825190455.GA14812@electric-eye.fr.zoreil.com>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41956 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751475AbWHYTH3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 15:07:29 -0400
To: netdev@vger.kernel.org, linux@youmustbejoking.demon.co.uk
Content-Disposition: inline
In-Reply-To: <4E5C083B8E%linux@youmustbejoking.demon.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darren Salt <linux@youmustbejoking.demon.co.uk> :
> In case you don't yet have an lspci dump for an RTL8136, here's one for a
> device which is working with the r1000 driver which is supplied with Ubuntu
> dapper (though the machine in question - a Toshiba Equium A110-233 - is
> actually running Debian testing.)

Thanks. The MM region was correctly guessed. If the driver does not work,
you can try to s/RTL_CFG_1/RTL_CFG_2/ for the 0x8136 entry in the
rtl8169_pci_tbl array.

-- 
Ueimor
