From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Tue, 3 Jul 2012 11:56:04 +0300
Message-ID: <4FF2B3A4.8000801@mellanox.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>   <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>  <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>  <4FF19ACD.6040602@mellanox.com> <1341280041.2590.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>, <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:35376 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751434Ab2GCI4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 04:56:12 -0400
In-Reply-To: <1341280041.2590.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/2012 4:47 AM, Ben Hutchings wrote:
> If the hardware can only match the VID then you need to validate that
> the mask is either 0 or 0xfff instead of 0 or 0xffff.

sure, will fix
