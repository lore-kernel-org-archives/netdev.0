From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Wireless Extensions WE-18 questions
Date: Sun, 8 Aug 2004 18:46:27 +0300
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040808154627.GC7138@jm.kir.nu>
References: <1091444633.2767.8.camel@rootix> <20040803070843.GB7153@jm.kir.nu>
	<1091929000.2800.12.camel@rootix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, netdev@oss.sgi.com, hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Pedro Ramalhais <ramalhais@serrado.net>
Content-Disposition: inline
In-Reply-To: <1091929000.2800.12.camel@rootix>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 08, 2004 at 02:36:40AM +0100, Pedro Ramalhais wrote:

> - what kind of information should be used in set_genie/get_genie
> requests? I know it's a pointer, but what is the information it points
> to? ipw2100 firmware expects: capabilities, listening interval,
> current_ap, var_ie_len and var_ie for setting IEs.

There are additional IEEE 802.11 information elements, including
identification and length bytes. The data area can include one more
multiple IEs (e.g., WPA, RSN, WME). Capabilities, listen interval, and
current AP would be from other ioctls.

> - How should IW_AUTH_CIPHER_PAIRWISE and IW_AUTH_CIPHER_GROUP be used
> with crypt_tkip/crypt_ccmp ?

I'm not sure what you mean with this. Cipher configuration is an
optional mechanism that some drivers can use for WPA configuration. This
is especially to make it easier to use drivers that were originally
designed for NDIS since they generate WPA IE based on the cipher
configuration whereas some of the (non-NDIS) drivers that I have worked
with get WPA IE from the Supplicant (i.e., they can share the same code
for this) and can ignore these values.

> PS: I was hoping someone had already answer my e-mail about the creation
> of a linux wireless mailing list, and this message would be sent to the
> new list... oh well

What's wrong with using netdev for this? I think this was the result
from the last time the topic of adding a new list came up and I don't
think anything have changed since then. As long as people don't complain
about getting too much messages about wireless development on netdev, I
don't see much point in adding a new list.

-- 
Jouni Malinen                                            PGP id EFC895FA
