From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tg3: capacitive coupling detection fix
Date: Fri, 11 Feb 2005 13:13:55 -0800
Message-ID: <20050211131355.5e084004.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3D93@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, johnstul@us.ibm.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D93@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 12:44:10 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> This patch fixes the problem reported in:
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=110798711911645&w=2
> 
> The 5700 link problem was caused by reading uninitialized values in sram and
> causing capacitive coupling mode to be enabled by mistake. This patch fixes
> the problem by properly validating the sram contents.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks a lot Michael.
