From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Mon, 10 Mar 2014 01:37:32 +0100
Message-ID: <531D094C.1090205@gmail.com>
References: <1394192092-27461-1-git-send-email-sebastian.hesselbarth@gmail.com> <20140309.191235.1047481546773873653.davem@davemloft.net> <531CF864.9040406@gmail.com> <20140309.203001.1318893833441564547.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140309.203001.1318893833441564547.davem@davemloft.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2014 01:30 AM, David Miller wrote:
> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Date: Mon, 10 Mar 2014 00:25:24 +0100
>
>> There is no way to determine if a bootloader is broken or not. The
>> sysfs knob allows to provide a use case based decision. Of course,
>> we can invent some freaky device tree property but that the DT
>> maintainers will not like either.
>
> My point is that whatever mechanism is used to "decide" that the sysfs
> knob gets set, can also be used to "decide" that a DT property is
> instantiated in the device tree.

The mechanism is manual, no automatic way to determine it. I understand
your point, but DT maintainers will argue here that DT is to describe HW
not SW. And a badly written bootloader initialization routine for a PHY
is SW.

Also, this will force us to maintain two sets of DT files for each
affected board: one for those with broken bootloader and one for those
with an updated, fixed bootloader. And of course, the broken bootloaders
are from pre-DT times and cannot even set that property but require the
user to pick the right DT.

If you are still against a sysfs knob, I see no way to provide a user
accessible way to prevent the PHY to be suspended. And the user is the
only reliable instance to decide not to suspend it.

Sebastian

