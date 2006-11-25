From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: jumbo frame support on realtek 8169
Date: Sat, 25 Nov 2006 15:19:47 +0100
Message-ID: <20061125141947.GA11374@electric-eye.fr.zoreil.com>
References: <ECECF744-AF81-42F9-AF0F-502E3906ECB9@insipid.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48257 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S935203AbWKYOVp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Nov 2006 09:21:45 -0500
To: Tim Jordan <tim@insipid.org.uk>
Content-Disposition: inline
In-Reply-To: <ECECF744-AF81-42F9-AF0F-502E3906ECB9@insipid.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Jordan <tim@insipid.org.uk> :
> Does the kernel driver support jumbo frames as I do not seem to be  
> able to enable it using ifconfig eth0 mtu 9000?

Due to hardware limitation, 7200 bytes is the safe upper limit.

Note: so far the driver applies the same limit to the 8168 but I
have not had reports nor seen documented that the 8168 exhibits the
exact same behavior. Feedback would be welcome.

-- 
Ueimor
