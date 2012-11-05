From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Mon, 05 Nov 2012 00:53:43 -0500 (EST)
Message-ID: <20121105.005343.973313737817968846.davem@davemloft.net>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com>
	<20121023.023647.2164665243829038911.davem@davemloft.net>
	<CAFWqQMSes5J1bjUA6NBiWKrjbdUKJkhz-mdNYhGLU-A8cksxZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: cardoe@cardoe.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFWqQMSes5J1bjUA6NBiWKrjbdUKJkhz-mdNYhGLU-A8cksxZg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Goldstein <cardoe@cardoe.com>
Date: Sun, 4 Nov 2012 23:45:56 -0600

> As Ben Greear pointed out this would allow shell scripts and other
> scripting languages to better detect vlans. Kay pointed out that this
> would allow better uevent filters in the future as well. So there are
> some merits to this patch. If you'd prefer I can resubmit with a
> better commit message entailing the reasons behind it.

For the thousandth time:

All of those scripts and other users of this new facility will
need to have backup code to detect vlan devices when this
sysfs thing is not present.

They are already to determine this information already, and
they alreayd have to be ugly to handle EVERY EXISTING KERNEL
ON THE PLANET.

So the effective value is zero.
