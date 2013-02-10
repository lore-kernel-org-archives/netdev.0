From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH] drivers: net: Remove remaining alloc/OOM messages
Date: Sun, 10 Feb 2013 09:57:54 +0200
Message-ID: <1877379.y4GS62BPgg@lx-vladimir>
References: <1360273587.27863.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <linux-usb@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@lists.ath9k.org>,
	<wil6210@qca.qualcomm.com>, <brcm80211-dev-list@broadcom.com>,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1360273587.27863.15.camel@joe-AO722>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, February 07, 2013 01:46:27 PM Joe Perches wrote:
> alloc failures already get standardized OOM
> messages and a dump_stack.
> 
> For the affected mallocs around these OOM messages:
> 
> Converted kmallocs with multiplies to kmalloc_array.
> Converted a kmalloc/memcpy to kmemdup.
> Removed now unused stack variables.
> Removed unnecessary parentheses.
> Neatened alignment.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 

For wil6210:

Acked--by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>

Thanks, Vladimir
