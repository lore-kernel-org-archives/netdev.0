From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH] tg3: capacitive coupling detection fix
Date: Fri, 11 Feb 2005 13:19:37 -0800
Message-ID: <1108156778.11683.212.camel@cog.beaverton.ibm.com>
References: <B1508D50A0692F42B217C22C02D84972020F3D93@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        lkml <linux-kernel@vger.kernel.org>, Chris McDermott <lcm@us.ibm.com>,
        keith maanthey <kmannth@us.ibm.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D93@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-02-11 at 12:44 -0800, Michael Chan wrote:
> This patch fixes the problem reported in:
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=110798711911645&w=2
> 
> 
> The 5700 link problem was caused by reading uninitialized values in sram and
> causing capacitive coupling mode to be enabled by mistake. This patch fixes
> the problem by properly validating the sram contents.

Verified as working on the x440 I was seeing the trouble with.

Thanks!
-john
