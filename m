From: Doug Goldstein <cardoe@cardoe.com>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Mon, 5 Nov 2012 00:19:19 -0600
Message-ID: <CAFWqQMRa6sPxqAJswu-6f06KxhqLSsY2T-dE3p-tpo4VEpwfdA@mail.gmail.com>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com>
	<20121023.023647.2164665243829038911.davem@davemloft.net>
	<CAFWqQMSes5J1bjUA6NBiWKrjbdUKJkhz-mdNYhGLU-A8cksxZg@mail.gmail.com>
	<20121105.005343.973313737817968846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121105.005343.973313737817968846.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 4, 2012 at 11:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Doug Goldstein <cardoe@cardoe.com>
> Date: Sun, 4 Nov 2012 23:45:56 -0600
>
>> As Ben Greear pointed out this would allow shell scripts and other
>> scripting languages to better detect vlans. Kay pointed out that this
>> would allow better uevent filters in the future as well. So there are
>> some merits to this patch. If you'd prefer I can resubmit with a
>> better commit message entailing the reasons behind it.
>
> For the thousandth time:
>
> All of those scripts and other users of this new facility will
> need to have backup code to detect vlan devices when this
> sysfs thing is not present.
>
> They are already to determine this information already, and
> they alreayd have to be ugly to handle EVERY EXISTING KERNEL
> ON THE PLANET.
>
> So the effective value is zero.

By this argument we shouldn't ever improve any API or add new syscalls
since we'll have to have fallback code to handle the old interfaces
when the new ones aren't available.

Since everything already has the existing implementations to handle
every existing kernel on the planet then this patch doesn't harm
anything and should I want to write a shell script that only works on
Linux 3.8 (assuming this patch is in there) and is only forward
looking then I can use the more complete sysfs.

So the effective penalty is zero and you get a more complete sysfs,
which is where you're value is.

-- 
Doug Goldstein
