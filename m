From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: remove bridge work
Date: Fri, 13 May 2016 21:28:28 -0400
Message-ID: <8737plig1v.fsf@ketchup.mtl.sfl>
References: <1463186303-3139-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463186303-3139-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> Now that the bridge code defers the switchdev port state setting, there
> is no need to defer the port STP state change within the mv88e6xxx code.
> Thus get rid of the driver's bridge work code.
>
> This also fixes a race condition where the DSA layer assumes that the
> bridge code already set the unbridged port's STP state to Disabled
> before restoring the Forwarding state.
>
> As a consequence, this also fixes the FDB flush for the unbridged port
> which now correctly occurs during the Forwarding to Disabled transition.
>
> Fixes: 0bc05d585d38 ("switchdev: allow caller to explicitly request attr_set as deferred")
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

This patch doesn't apply to -net, only applies to net-next...

How should I handle that, do I resend a patch for net-next with the good
subject prefix, and a v2 for -net?

Sorry for the noise,

      Vivien
