From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] brcmsmac: Use current logging styles
Date: Sun, 13 Nov 2011 17:10:30 -0800
Message-ID: <1321233030.15834.12.camel@Joe-Laptop>
References: <1321213264.15834.4.camel@Joe-Laptop>
	 <20111113170825.6633b17e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111113170825.6633b17e@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-11-13 at 17:08 -0800, Stephen Hemminger wrote:
> On Sun, 13 Nov 2011 11:41:04 -0800
> Joe Perches <joe@perches.com> wrote:
> 
> > Add and use pr_fmt and pr_<level>
> > Remove useless double parentheses from macros.
> > Remove function names from format strings, add to pr_debug use.
> > Coalesce formats.
> > Remove uncompileable undeclared variable in a DMA_NONE use.
> 
> If you are going to change it why not got all the way to netdev_XXX and dev_XXX macros
> instead.

No dev always available, simpler change,
mirrors the changes in brcmfmac.
