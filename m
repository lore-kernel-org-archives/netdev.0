From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Mon, 10 Nov 2014 16:42:25 +0000
Message-ID: <5460EAF1.5020903@citrix.com>
References: <20141106214940.GD44162@ubuntu-hedt> <545CA27F.4070400@citrix.com>	<20141110143517.GA74005@ubuntu-hedt> <5460CEA5.3070201@citrix.com> <5460EA45.2080202@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Zoltan Kiss <zoltan.kiss@linaro.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5460EA45.2080202@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/14 16:39, Zoltan Kiss wrote:
> 
> The BUG_ON suggested by Stefan would be still reasonable:
> 
> BUG_ON(((page-compound_head(page))*PAGE_SIZE)+offset+len >
> PAGE_SIZE<<compound_order(compound_head(page)));

Well, it wouldn't trigger but I don't think it is useful any more.

David
