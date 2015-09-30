From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 0/3] net: dsa: Complete and fix the dsa unbinding
Date: Wed, 30 Sep 2015 10:43:54 -0700
Message-ID: <560C1F5A.5070506@gmail.com>
References: <560B9B70.6030202@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	linux@roeck-us.net
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560B9B70.6030202@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/09/15 01:21, Neil Armstrong wrote:
> In order to cleanly unbind the dsa core, either as a module removal,
> or a platform device unbind, switch the allocation the their devm_
> counterparts and complete the destroy functions.
> 
> The last patch is an experimental way to exit the probe when no
> switch is found in the discover process.
> 
> The patches are based on the current net-next.

I looked at the patches and they bring DSA in a better direction. For
future submissions, could you CC people who recently worked on DSA, like
Andrew Lunn, Guenter Roeck, Vivien Didelot and myself? We can typically
give your patches a try fairly quickly.

In case you are seriously considering making DSA a loadable module,
there were an earlier attempt here:

http://comments.gmane.org/gmane.linux.network/345803

Thanks!

> 
> Neil Armstrong (3):
>   net: dsa: Use devm_ prefixed allocations
>   net: dsa: complete dsa_switch_destroy calls
>   net: dsa: exit probe if no switch were found
> 
>  net/dsa/dsa.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 60 insertions(+), 7 deletions(-)
> 


-- 
Florian
