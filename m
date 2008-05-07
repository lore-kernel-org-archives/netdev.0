From: "Julius Volz" <juliusv@google.com>
Subject: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Wed, 7 May 2008 16:32:13 +0200
Message-ID: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Simon Horman" <horms@verge.net.au>,
	"David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm resending this since I didn't get any feedback on it the first
time around. I redid the patch to apply to the current net-2.6 tree.
Please let me know if there are any issues with it!

Thanks,
Julius

On Fri, Apr 4, 2008 at 12:40 PM, Julius Volz <juliusv@google.com> wrote:
> Hi,
>
>  This patch moves IPVS from net/ipv4/ipvs to net/netfilter/ipvs, as
>  discussed earlier with Horms and Patrick McHardy. This is done as a
>  preparation for later adding IPv6 functionality to IPVS. The patch is
>  600kb, so I uploaded it here:
>
>  http://www-user.tu-chemnitz.de/~volz/move_ipvs_to_netfilter.patch
>
>  --------------------------
>  Description:
>  Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs as a preparation
>  for adding IPv6 support to IPVS later on.
>
>  Signed-off-by: Julius R. Volz <juliusv@google.com>
>  --------------------------
>
>  It applies to the current net-2.6 tree and IPVS is working after these
>  changes. The patch also moves the IPVS menu options into the Netfilter
>  menu subtree. Please let me know if that is ok or has to be changed
>  (it seems ok to me, as IPVS depends on Netfilter).
>
>  Again, I'm pretty new to kernel development, so let me know of
>  anything that can be done better.
>
>  Thanks,
>  Julius Volz
>
>  --
>  Google Switzerland GmbH
>

-- 
Google Switzerland GmbH
