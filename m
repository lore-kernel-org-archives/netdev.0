From: "David S. Miller" <davem@redhat.com>
Subject: Re: Dealing with buggy hardware (was: b44 and 4g4g)
Date: Sat, 5 Jun 2004 13:19:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605131923.232f8950.davem@redhat.com>
References: <20040531202104.GA8301@ee.oulu.fi>
	<20040605200643.GA2210@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040605200643.GA2210@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Jun 2004 23:06:44 +0300
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> +	if(virt_to_bus(skb->data) + skb->len > B44_PCI_DMA_MAX) {

You can't use this non-portable interface, you have to:

1) pci_map the data
2) test the dma_addr_t returned
