From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/8] net: dsa: mv88e6xxx: add switch register helpers
Date: Thu, 09 Jun 2016 08:53:53 -0400
Message-ID: <878tyewmji.fsf@ketchup.mtl.sfl>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com> <20160609004456.5441-6-vivien.didelot@savoirfairelinux.com> <20160609023934.GK2227@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609023934.GK2227@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Jun 08, 2016 at 08:44:53PM -0400, Vivien Didelot wrote:
>> Extract the allocation and registration code related to the dsa_switch
>> structure in a mv88e6xxx_register_switch helper function.
>> 
>> For symmetry in the code, add a mv88e6xxx_unregister_switch function.
>
> You say what you are doing, but not why?

The mixed assignements and registrations in the probe code make it hard
to read and figure out what is dsa or chip specific, so I made that
change to provide a simple function doing one thing, make it easier to
follow the probe logic.

Thanks, I'll update the commit message.

        Vivien
