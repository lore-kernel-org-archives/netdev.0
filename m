From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 19/20] net: dsa: mv88e6xxx: factorize tag protocol
Date: Fri, 06 May 2016 16:56:48 -0400
Message-ID: <871t5eaorz.fsf@ketchup.mtl.sfl>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1462488064-1841-20-git-send-email-vivien.didelot@savoirfairelinux.com> <20160506010949.GM7972@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160506010949.GM7972@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Thu, May 05, 2016 at 06:41:03PM -0400, Vivien Didelot wrote:
>> 6131 is the only driver to set the tag protocol to DSA_TAG_PROTO_DSA.
>> Since it works fine with DSA_TAG_PROTO_EDSA, change its value, like all
>> other mv88e6xxx drivers.
>
> You might as well remove net/dsa/tag_dsa.c as well, since it is now
> unused. Please do that as a separate patch.

Why not, but isn't it a bit out of the scope of this patchset?

Thanks,

        Vivien
