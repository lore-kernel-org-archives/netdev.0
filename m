From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: fix header length calculation in
 ip6_append_data()
Date: Thu, 17 Jan 2013 03:37:40 -0500 (EST)
Message-ID: <20130117.033740.1579145176326281217.davem@davemloft.net>
References: <F2E313A0-60C5-49DE-BBB7-BAEF532C0433@ipflavors.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	steffen.klassert@secunet.com, linux-kernel@vger.kernel.org
To: r.kuntz@ipflavors.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F2E313A0-60C5-49DE-BBB7-BAEF532C0433@ipflavors.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain KUNTZ <r.kuntz@ipflavors.com>
Date: Wed, 16 Jan 2013 23:47:40 +0100

> Commit 299b0767 (ipv6: Fix IPsec slowpath fragmentation problem)
> has introduced a error in the header length calculation that 
> provokes corrupted packets when non-fragmentable extensions 
> headers (Destination Option or Routing Header Type 2) are used.
> 
> rt->rt6i_nfheader_len is the length of the non-fragmentable 
> extension header, and it should be substracted to
> rt->dst.header_len, and not to exthdrlen, as it was done before
> commit 299b0767.
> 
> This patch reverts to the original and correct behavior. It has
> been successfully tested with and without IPsec on packets
> that include non-fragmentable extensions headers.
> 
> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks.
