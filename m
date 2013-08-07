From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 1/5] netfilter: nf_conntrack: make sequence number
 adjustments usuable without NAT
Date: Wed, 7 Aug 2013 22:02:10 +0200
Message-ID: <20130807220210.05808b0d@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1375897371-18430-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  7 Aug 2013 19:42:47 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Split out sequence number adjustments from NAT and move them to the
> conntrack core to make them usable for SYN proxying. The sequence
> number adjustment information is moved to a seperate extend. The
> extend is added to new conntracks when a NAT mapping is set up for a
> connection using a helper.
> 
> As a side effect, this saves 24 bytes per connection with NAT in the
> common case that a connection does not have a helper assigned.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
