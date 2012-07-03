From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Tue, 3 Jul 2012 11:14:05 +0300
Message-ID: <4FF2A9CD.7010201@mellanox.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F70@saturn3.aculab.com> <m28vf2o0oa.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Joe Perches <joe@perches.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, Hadar Hen Zion <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:56874 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932166Ab2GCIOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 04:14:49 -0400
In-Reply-To: <m28vf2o0oa.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2012 2:35 PM, Andreas Schwab wrote:
>
> 	field == 0 || field == (typeof field)~(typeof field)0
> You can avoid that by using (typeof field)-1.
>

OK, thanks everybody, we will take that path.

Or.
