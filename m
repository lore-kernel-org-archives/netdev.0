From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq
Date: Mon, 8 Aug 2016 13:10:54 +0200
Message-ID: <20160808111054.GA4915@salvia>
References: <20160803104141.12CDB1A2394@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160803104141.12CDB1A2394@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 03, 2016 at 12:41:40PM +0200, Christophe Leroy wrote:
> Do not drop packet when CSeq is 0 as 0 is also a valid value for CSeq.
> 
> simple_strtoul() will return 0 either when all digits are 0
> or if there are no digits at all. Therefore when simple_strtoul()
> returns 0 we check if first character is digit 0 or not.

Applied, thanks.
