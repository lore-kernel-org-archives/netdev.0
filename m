From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] filter: add SKF_AD_NLATTR_NEST to look for nested attributes
Date: Tue, 18 Nov 2008 11:49:18 +0100
Message-ID: <49229DAE.6060105@trash.net>
References: <20081118030112.28254.90533.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081118030112.28254.90533.stgit@Decadence>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
> SKF_AD_NLATTR allows us to find the first matching attribute in a
> stream of netlink attributes from one offset to the end of the
> netlink message. This is not suitable to look for a specific
> matching inside a set of nested attributes.
> 
> For example, in ctnetlink messages, if we look for the CTA_V6_SRC
> attribute in a message that talks about an IPv4 connection,
> SKF_AD_NLATTR returns the offset of CTA_STATUS which has the same
> value of CTA_V6_SRC but outside the nest. To differenciate
> CTA_STATUS and CTA_V6_SRC, we would have to make assumptions on the
> size of the attribute and the usual offset, resulting in horrible
> BSF code.
> 
> This patch adds SKF_AD_NLATTR_NEST, which is a variant of
> SKF_AD_NLATTR, that looks for an attribute inside the limits of
> a nested attributes, but not further.
> 
> This patch validates that we have enough room to look for the
> nested attributes - based on a suggestion from Patrick McHardy.

Looks good, thanks Pablo.

Acked-by: Patrick McHardy <kaber@trash.net>
