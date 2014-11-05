From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] Implement ndo_gso_check() for vxlan nics
Date: Wed, 05 Nov 2014 16:38:25 -0500 (EST)
Message-ID: <20141105.163825.1433973842938441546.davem@davemloft.net>
References: <CANr6G5xtNYenhd8KDWx+kRcnSZ0fahUdAL+6Wcz=5_dNvrQR6Q@mail.gmail.com>
	<CA+mtBx_BOmV+tOtio48M+xRatK79B31LoGnf4uvFJAbxYqOt_w@mail.gmail.com>
	<CAJ3xEMhxabp1EKbFPfvoZEFt=CQKFNcNrURGMX=7miDwmK9Y-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, joestringer@nicira.com,
	netdev@vger.kernel.org, sathya.perla@emulex.com,
	jeffrey.t.kirsher@intel.com, linux.nics@intel.com,
	amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-kernel@vger.kernel.org
To: gerlitz.or@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMhxabp1EKbFPfvoZEFt=CQKFNcNrURGMX=7miDwmK9Y-A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Wed, 5 Nov 2014 23:32:44 +0200

> but fact is that the proposed patch series has the --same-- helper for
> four drivers, so why not start with a that limited helper which would
> be picked up by these drivers and we'll take it from there.

I'm in favor of the helper, duplication is error prone.

And in fact, any differences a driver ends up needing might be
integratable into the helper.
