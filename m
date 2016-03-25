From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: fix 6185 hardware bridging
Date: Fri, 25 Mar 2016 13:20:30 -0400
Message-ID: <87r3eyscdd.fsf@ketchup.mtl.sfl>
References: <1458925319-16771-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458925319-16771-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> The 88E6185 switch also has a MapDA bit in its Port Control 2 register.
> When this bit is cleared, all frames are sent out to the CPU port.
>
> Set this bit to rely on ATU hits and direct the frame out of the correct
> ports, and thus enable hardware bridging.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Andrew, I sent this patch too fast. It requires a proper support of the
ATU in order to populate the FDB correctly. I send that soon.

David, please ignore this patch for the moment.

Thanks,
Vivien
