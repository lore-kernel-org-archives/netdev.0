From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.10] tg3: 5704 serdes fixes
Date: Wed, 2 Feb 2005 16:08:51 -0800
Message-ID: <20050202160851.27e532f6.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3D56@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D56@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 14:43:34 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> Some 5704S and related fixes:
> 
> - Fix capacitive coupling detection by reading the correct offset in sram
> - Add support for different signal pre-emphasis on 5704S (used in some blade
> servers)
> - Improve 5704S link parallel detection. When autonegotiation fails, we only
> detect link-up if we have PCS_SYNC and we are not receiving config code
> words. This will prevent false link-up when only the rx cable is attached.

Applied, thanks Michael.
