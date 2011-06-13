From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH] ieee802154: Don't leak memory in ieee802154_nl_fill_phy
Date: Tue, 14 Jun 2011 00:02:38 +0400
Message-ID: <BANLkTikBnQADmUpP7J5gmJLXA9-O+4kSvw@mail.gmail.com>
References: <alpine.LNX.2.00.1106121621360.25151@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	Maxim Osipov <maxim.osipov@siemens.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106121621360.25151@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/12/11, Jesper Juhl <jj@chaosbits.net> wrote:
> In net/ieee802154/nl-phy.c::ieee802154_nl_fill_phy() I see two small
> issues.
> 1) If the allocation of 'buf' fails we may just as well return -EMSGSIZE
>    directly rather than jumping to 'out:' and do a pointless kfree(0).
> 2) We do not free 'buf' unless we jump to one of the error labels and this
>    leaks memory.
> This patch should address both.
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Acked-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

David, please commit this.

-- 
With best wishes
Dmitry
