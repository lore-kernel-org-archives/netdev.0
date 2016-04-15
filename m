From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/7] net: dsa: mv88e6xxx: add number of database to info
Date: Fri, 15 Apr 2016 16:24:26 -0400
Message-ID: <87mvouaadh.fsf@ketchup.mtl.sfl>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1460744750-13896-7-git-send-email-vivien.didelot@savoirfairelinux.com> <20160415193516.GD18523@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160415193516.GD18523@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, Apr 15, 2016 at 02:25:49PM -0400, Vivien Didelot wrote:
>> Move the number of databases to the info structure.
>
> Isn't the number of databases a property of the family?

No.

We've seen [1] for instance that 6061 and 6065 are both part of the 6065
family, but 6061 has 16 databases while 6065 has 64 databases.

> I would add a table indexed by family.

I'm not even sure every Marvell switch has a family. I think we really
want a table of supported *devices*.

To go further, with the coming feature-based logic, checking the family
might not even be that valuable.

[1] https://lkml.org/lkml/2016/3/26/155

Thanks,
Vivien
