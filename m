From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 8/8] net: dsa: mv88e6xxx: fail on mismatching probe
Date: Fri, 10 Jun 2016 16:32:03 -0400
Message-ID: <87fuskkcos.fsf@ketchup.mtl.sfl>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com> <20160609004456.5441-9-vivien.didelot@savoirfairelinux.com> <20160609022149.GF2227@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609022149.GF2227@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Jun 08, 2016 at 08:44:56PM -0400, Vivien Didelot wrote:
>> Now that we have access at probe time to the chip info described in the
>> device tree, check if the probed device matches the device node,
>> otherwise warn the user and fail.
>
> What good is this? So what if the device tree says a different
> model. We don't care, we don't use that information at all, we read it
> from the device itself.

So we can end up with a badly described device tree. It seems to be a
question of rigor vs. flexibility. I don't know much about the DT
philosophy and I don't really mind as long as we warn the user.

I'd like to have other opinions on this though before pushing v2.

Thanks,

        Vivien
