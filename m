From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1]  ftp: get or put stops during
 file-transfer
Date: Tue, 19 Dec 2006 05:55:11 +0900
Message-ID: <20061219055511.15924b4a.komurojun-mbn@nifty.com>
References: <20061217212752.d93816b4.komurojun-mbn@nifty.com>
	<20061217040222.GD17561@ftp.linux.org.uk>
	<20061217232311.f181302f.komurojun-mbn@nifty.com>
	<20061218030113.GT10316@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Al Viro <viro@ftp.linux.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753888AbWLRLxo@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061218030113.GT10316@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> What network cards are in the client and the server?

DL10022-based pcmcia network card(both client and server)
The driver name is pcnet_cs.
 
> Are there any error messages your client gives or in the log files?

no error messages.

I capture the packet of ftp transfer by ethereal.
I found the malformed packet when it stops.

I will investigate it further.

Thanks!

Best Regards
Komuro
