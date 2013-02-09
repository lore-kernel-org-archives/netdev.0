From: Joe Perches <joe@perches.com>
Subject: Other alloc/OOM message question
Date: Fri, 08 Feb 2013 16:29:59 -0800
Message-ID: <1360369799.13487.5.camel@joe-AO722>
References: <1360273587.27863.15.camel@joe-AO722>
	 <20130208.174500.1518593039138341685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130208.174500.1518593039138341685.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-08 at 17:45 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 07 Feb 2013 13:46:27 -0800
> > alloc failures already get standardized OOM
> > messages and a dump_stack.

Does anyone know if all the other alloc's like
dma_alloc_coherent, dma_alloc_noncoherent,
pci_alloc_consistent always produce OOM messages
via page_alloc/warn_alloc_failed for all arches?

If so, there are many more of these OOM messages
that could be removed.
