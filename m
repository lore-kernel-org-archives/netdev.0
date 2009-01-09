From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: PROBLEM: networking - port 80 not accessible on eth0
Date: Fri, 9 Jan 2009 16:43:41 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901091637350.1889@wrl-59.cs.helsinki.fi>
References: <af2dae3d0901082220i6d819f31tfb26ac9ad57f750@mail.gmail.com>
 <af2dae3d0901090401l19ea59b6j1812c9d16c843116@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Orgad Shaneh <orgads@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37985 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbZAIOnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 09:43:43 -0500
In-Reply-To: <af2dae3d0901090401l19ea59b6j1812c9d16c843116@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0901091637352.1889@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added netdev though this is unlikely to end up being dev related.

On Fri, 9 Jan 2009, Orgad Shaneh wrote:

> ---------- Forwarded message ----------
> From: Orgad Shaneh <orgads@gmail.com>
> Date: Fri, Jan 9, 2009 at 8:20 AM
> Subject: PROBLEM: networking - port 80 not accessible on eth0
> To: linux-kernel@vger.kernel.org
> 
> 
> I have a "VIA Technologies, VIA Technologies, Inc. VT6102 [Rhine-II]"
> NIC connected to an ECI B-FOCuS 270PR ADSL model. I used fedora since
> version 5. On FC5 (using kernel 2.6.15) the modem functioned as a
> router, and it worked fine.
> 
> When I upgraded to FC6 (which was published with kernel 2.6.18) I
> couldn't access any websites. I found out that I can access https, ftp
> etc. but not http. I figured out that for some reason, port 80 was
> blocked. When using VMWare with Windows, I could access websites.
> 
> I configured the modem to be a bridge, and I'm connecting through
> pppoe. This way it works. Anyway, although I can access websites on
> ppp0, I cannot access the modem itself (for configuration), which is
> on eth0 port 80.
> 
> I attached a tcpdump when trying to connect to the modem (the same
> applies for websites, when the modem is configured as a gateway):
> 
> After trying some different distributions (fedora up to 9, ubuntu 8.04
> and 8.10), the problem remains. That's what leads me to the conclusion
> that the problem is in the kernel.

Unlikely so, more likely the router is broken and some kernel TCP settings 
got changed in the newer kernels. I took a short look into the provided 
tcpdump and the modem negotiates tcp connection ok but then goes dead 
silent.

Your could try playing around with tcp_window_scaling sysctl,
most likely the modem has some problem related to it.


-- 
 i.
