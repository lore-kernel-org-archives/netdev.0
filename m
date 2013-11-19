From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] netfilter: synproxy: send mss option to backend
Date: Tue, 19 Nov 2013 15:35:24 +0100
Message-ID: <20131119143524.GA7370@localhost>
References: <1384439731-16296-1-git-send-email-mph@one.com>
 <1384439731-16296-2-git-send-email-mph@one.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Topholm <mph@one.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1384439731-16296-2-git-send-email-mph@one.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2013 at 03:35:30PM +0100, Martin Topholm wrote:
> When the synproxy_parse_options is called on the client ack the mss
> option will not be present. Consequently mss wont be included in the
> backend syn packet, which falls back to 536 bytes mss.
> 
> Therefore XT_SYNPROXY_OPT_MSS is explicitly flagged when recovering mss
> value from cookie.

Applied, thanks Martin.
