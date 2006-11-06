From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC: 2.6 patch] bcm43xx_sprom_write(): add error checks
Date: Mon, 06 Nov 2006 09:50:03 -0600
Message-ID: <454F59AB.9090403@lwfinger.net>
References: <20061106142146.GN5778@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-02.rdc-kc.rr.com ([24.94.166.122]:56040 "EHLO
	ms-smtp-02.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1753265AbWKFPum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 10:50:42 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061106142146.GN5778@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> The Coverity checker noted that these "if (err)"'s couldn't ever be 
> true.
> 
> It seems the intention was to check the return values of the 
> bcm43xx_pci_write_config32()'s?

Exactly. This patch sent to wireless-2.6.

Thanks,

Larry
