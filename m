From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Sun, 27 Nov 2016 22:50:22 +0100
Message-ID: <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Florian Fainelli <f.fainelli@gmail.com>,
 Michal Hrusecki <Michal.Hrusecky@nic.cz>,
 =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Tomas Hlavacek <tomas.hlavacek@nic.cz>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Bed??icha Ko??atu <bedrich.kosata@nic.cz>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161127212709.GD13318@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Am 27.11.2016 um 22:27 schrieb Andrew Lunn:
> On Sun, Nov 27, 2016 at 09:57:59PM +0100, Andreas F=E4rber wrote:
>> This model is found on the Turris Omnia.
> =

> This driver already supports nearly 30 different Marvell switch
> models. Please document why the marvell,mv88e6176 is special and why
> it needs its own compatible string when the others don't.

I don't understand.

The commit message above already points out for which device this is
(and you also know from the LAKML thread).

You as driver author should know that the .data pointer is vital to your
driver - you even recently accepted another model that conflicted with
my patch. So are you arguing for a ", which uses a Device Tree for
booting" half-sentence here?

The others not having an entry simply means no one needed them yet.

And any Turris Omnia side changes need to go through the mvebu tree.

Regards,
Andreas

-- =

SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N=FCrnberg)
