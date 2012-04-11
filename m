From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: xt_recent: Add optional mask option for
 xt_recent
Date: Thu, 12 Apr 2012 01:14:21 +0200
Message-ID: <20120411231421.GA7038@1984>
References: <1331033084-23803-1-git-send-email-denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331033084-23803-1-git-send-email-denys@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Denys,

On Tue, Mar 06, 2012 at 01:24:44PM +0200, Denys Fedoryshchenko wrote:
> Use case for this feature:
> 1)In some occasions if you need to allow,block,match specific subnet.
> 2)I can use recent as a trigger when netfilter rule matches, with mask 0.0.0.0
> 
> Example:
> 
> If you ping 8.8.8.8, after that you can't ping 2.2.2.10

Could you provide an useful example for this new feature?

I also think you can make this with hashlimit, that allows you to
set the network mask.
