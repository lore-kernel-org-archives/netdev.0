From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (3/4) acenic - __iomem warnings cleanup
Date: Mon, 20 Sep 2004 13:55:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F199B.3090806@pobox.com>
References: <20040920104431.0a96d6c1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@wildopensource.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040920104431.0a96d6c1@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Remaining warnings are because tx_ring can be either in i/o or not
> depending on the version of the card.

Where is this code?  I don't see any {in,out}[bwl] calls?

If this were true, we should use io{read,write}{8,16,32}...

	Jeff
