From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] netfilter: synproxy: correct wscale option passing
Date: Tue, 19 Nov 2013 15:35:33 +0100
Message-ID: <20131119143533.GB7370@localhost>
References: <1384439731-16296-1-git-send-email-mph@one.com>
 <1384439731-16296-3-git-send-email-mph@one.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Topholm <mph@one.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1384439731-16296-3-git-send-email-mph@one.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2013 at 03:35:31PM +0100, Martin Topholm wrote:
> Timestamp are used to store additional syncookie parameters such as sack,
> ecn, and wscale. The wscale value we need to encode is the client's
> wscale, since we can't recover that later in the session. Next overwrite
> the wscale option so the later synproxy_send_client_synack will send
> the backend's wscale to the client.

Also applied, thanks.
