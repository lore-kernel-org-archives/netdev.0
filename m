From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] netfilter: xt_TEE depends on NF_CONNTRACK
Date: Fri, 14 May 2010 13:52:39 -0700 (PDT)
Message-ID: <20100514.135239.149842985.davem@davemloft.net>
References: <20100514161407.740da901.sfr@canb.auug.org.au>
	<20100514101218.16cdb0ad.randy.dunlap@oracle.com>
	<4BED8650.5040808@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4BED8650.5040808@trash.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 14 May 2010 19:20:16 +0200

> Randy Dunlap wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>> 
>> Fix xt_TEE build for the case of NF_CONNTRACK=m and
>> NETFILTER_XT_TARGET_TEE=y:
>> 
>> xt_TEE.c:(.text+0x6df5c): undefined reference to `nf_conntrack_untracked'
>> 4x
>> 
>> Built with all 4 m/y combinations.
>> 
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Cc:	Patrick McHardy <kaber@trash.net>
>> Cc:	Jan Engelhardt <jengelh@medozas.de>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>
> 
> Dave, please apply directly. Thanks!

Done, thanks everyone.
