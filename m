From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] Implement ndo_gso_check() for vxlan nics
Date: Wed, 05 Nov 2014 21:15:58 -0500 (EST)
Message-ID: <20141105.211558.969082848816106943.davem@davemloft.net>
References: <CAJ3xEMhxabp1EKbFPfvoZEFt=CQKFNcNrURGMX=7miDwmK9Y-A@mail.gmail.com>
	<20141105.163825.1433973842938441546.davem@davemloft.net>
	<20141106010501.GA18339@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, therbert@google.com, netdev@vger.kernel.org,
	sathya.perla@emulex.com, jeffrey.t.kirsher@intel.com,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-kernel@vger.kernel.org
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106010501.GA18339@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Wed, 5 Nov 2014 17:06:46 -0800

> My impression was that the changes are more likely to be
> hardware-specific (like the i40e changes) rather than software-specific,
> like changes that might be integrated into the helper.

I think there is more commonality amongst hardware capabilities,
and this is why I want the helper to play itself out.

> That said, I can rework for one helper. The way I see it would be the
> same code as these patches, as "vxlan_gso_check(struct sk_buff *)" in
> drivers/net/vxlan.c which would be called from each driver. Is that what
> you had in mind?

Yes.
