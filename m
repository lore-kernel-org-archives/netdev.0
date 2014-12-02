From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 2 Dec 2014 17:09:27 +0000
Message-ID: <20141202170927.GA9457@casper.infradead.org>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com>
 <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org>
 <20141202154839.GB5344@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Du, Fan" <fan.du@intel.com>, 'Jason Wang' <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>, dev@openvswitch.org, mst@redhat.com,
	jesse@nicira.com, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37713 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbaLBRJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:09:32 -0500
Content-Disposition: inline
In-Reply-To: <20141202154839.GB5344@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/14 at 01:48pm, Flavio Leitner wrote:
> What about containers or any other virtualization environment that
> doesn't use Virtio?

The host can dictate the MTU in that case for both veth or OVS
internal which would be primary container plumbing techniques.

ivshmem would need it's own fix.
