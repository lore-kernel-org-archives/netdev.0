From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next] r8152: fix the wrong return value
Date: Mon, 6 Jan 2014 11:20:43 +0800
Message-ID: <85A9FCBA3D724C2FA135DD70BCF1FF4F@realtek.com.tw>
References: <1388719316-5702-1-git-send-email-hayeswang@realtek.com> <20140103.203759.2168117129392277198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:33957 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaAFDUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 22:20:43 -0500
In-Reply-To: <20140103.203759.2168117129392277198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, January 04, 2014 9:38 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next] r8152: fix the wrong return value
> 
> From: Hayes Wang <hayeswang@realtek.com>
> Date: Fri, 3 Jan 2014 11:21:56 +0800
> 
> > The return value should be the boolean value, not the error code.
> > 
> > Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> > Spotted-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Applied, but I agree with others that it's more canonical to have the
> function return either an error code, or zero for success, rather than
> a boolean.

Thanks. I would find if there is suitable error code.
 
Best Regards,
Hayes
