From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] NFC: nci: hci: Fix releasing uninitialized skbs
Date: Mon, 8 Jun 2015 23:49:23 +0200
Message-ID: <20150608214923.GH5089@ribalta.mp.intel.com>
References: <1433119485.2984.36.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1433119485.2984.36.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Sun, May 31, 2015 at 05:44:45PM -0700, Joe Perches wrote:
> Several of these goto exit; uses should be direct returns
> as skb is not yet initialized by nci_hci_get_param().
> 
> Miscellanea:
> 
> o Use !memcmp instead of memcmp() == 0
> o Remove unnecessary goto from if () {... goto exit;} else {...} exit:
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/nfc/nci/hci.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
Applied to nfc-next, thanks.

Cheers,
Samuel.
