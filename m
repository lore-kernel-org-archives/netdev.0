From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] nfc: Ensure presence of required attributes in the
 activate_target netlink handler
Date: Fri, 23 Jun 2017 00:29:35 +0200
Message-ID: <20170622222935.GF21214@zurbaran.ger.intel.com>
References: <20170524104226.14841-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Mateusz Jurczyk <mjurczyk@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170524104226.14841-1-mjurczyk@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mateusz,

On Wed, May 24, 2017 at 12:42:26PM +0200, Mateusz Jurczyk wrote:
> Check that the NFC_ATTR_TARGET_INDEX and NFC_ATTR_PROTOCOLS attributes (in
> addition to NFC_ATTR_DEVICE_INDEX) are provided by the netlink client
> prior to accessing them. This prevents potential unhandled NULL pointer
> dereference exceptions which can be triggered by malicious user-mode
> programs, if they omit one or both of these attributes.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
> ---
>  net/nfc/netlink.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
Applied, thanks.

Cheers,
Samuel.
