From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Thu, 21 Jul 2016 10:46:56 -0400
Message-ID: <87zipbm4kf.fsf@ketchup.mtl.sfl>
References: <20160720222641.30899-1-vivien.didelot@savoirfairelinux.com> <20160721003545.GB22834@lunn.ch> <2af1c57a-b1f1-7d6e-ef72-4f4c34830045@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2af1c57a-b1f1-7d6e-ef72-4f4c34830045@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46lorian Fainelli <f.fainelli@gmail.com> writes:

> Le 20/07/2016 =C3=A0 17:35, Andrew Lunn a =C3=A9crit :
>> On Wed, Jul 20, 2016 at 06:26:41PM -0400, Vivien Didelot wrote:
>>> This patch simply moves the legacy DSA code from dsa.c to legacy.c,
>>> except the few shared symbols which remain in dsa.c.
>>=20
>> I think it is a bit early for this. Lets convert all in kernel users
>> to the new binding first.
>
> Fine with me, let's try to get the in-tree DTS files converted to the
> new binding by v4.9 so we can then introduce this Kconfig symbol and
> start producing warnings if the old binding is encountered, how does
> that sound?

If you guys prefer going that way, that's fine with me too ;-)

Thanks,

        Vivien
