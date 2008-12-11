From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: xt_NFLOG is dependant of nfnetlink_log
Date: Wed, 10 Dec 2008 17:24:54 -0800 (PST)
Message-ID: <20081210.172454.178901962.davem@davemloft.net>
References: <1228934630.5961.8.camel@ice-age>
	<1228934957-11967-1-git-send-email-eric@inl.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kamalesh@linux.vnet.ibm.com, randy.dunlap@oracle.com,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, kaber@trash.net
To: eric@inl.fr
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1228934957-11967-1-git-send-email-eric@inl.fr>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Leblond <eric@inl.fr>
Date: Wed, 10 Dec 2008 19:49:17 +0100

> The patch "don't call nf_log_packet in NFLOG module" make xt_NFLOG
> dependant of nfnetlink_log. This patch forces the dependencies to fix
> compilation in case only xt_NFLOG compilation was asked and modifies the
> help message accordingly to the change.
> 
> Signed-off-by: Eric Leblond <eric@inl.fr>

I've applied this to net-next-2.6, thanks Eric.
