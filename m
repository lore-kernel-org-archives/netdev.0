From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH] ethtool: add new emac_regs struct from driver, add new
 chip types.
Date: Wed, 7 Oct 2015 11:41:31 +0400
Message-ID: <20151007114131.78a925c0@fr-ThinkPad-W520>
References: <20150923144634.2ea2bce9@fr-ThinkPad-W520>
	<20150925081545.26cbb101@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "" <netdev@vger.kernel.org>, "" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150925081545.26cbb101@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Sep 2015 08:15:45 +0400
"Ivan Mikhaylov" <ivan@ru.ibm.com> wrote:

ping 

> * add new version of emac_regs struct from driver structure
> perspective and passing size from actual struct size, not from memory
> area variable which set in dts file.
> * add three types of network chips for new struct : emac, emac4,
> emac4sync.
> * add emac4sync processing in print_emac_regs.
> * this commit fixing problem with output of MII sections for new
> driver versions.
> 
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
> ---
