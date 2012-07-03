From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Tue, 3 Jul 2012 11:58:36 +0300
Message-ID: <4FF2B43C.9040007@mellanox.com>
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
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:38106 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752642Ab2GCI6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 04:58:44 -0400
In-Reply-To: <1341280041.2590.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/2012 4:47 AM, Ben Hutchings wrote:
>> Under this logic, we can use the values and not the masks, isn't that?
> No, it's perfectly valid to specify a filter that matches, for example,
> a destination IP address of 0.0.0.0 with mask of 255.255.255.255.  So
> you really need to check the mask.  If your filter hardware doesn't
> support zero values for some fields then you'll need to reject them in
> mlx4_en_validate_flow.

Got it, will change to use masks all over the place, as you pointed out 
we need to do.
