From: =?UTF-8?B?IkFuZHkgR3JlZW4gKOael+WuieW7uCki?= <andy@warmcat.com>
Subject: Re: [PATCH 4 0/4] Add ability to set defaultless network device MAC
 addresses to deterministic computed locally administered values
Date: Tue, 10 Jul 2012 20:58:58 +0800
Message-ID: <4FFC2712.9020208@warmcat.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com> <201207101437.54877.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201207101437.54877.florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/12 20:37, the mail apparently from Florian Fainelli included:

Hi -

> Le jeudi 05 juillet 2012 04:44:33, Andy Green a =C3=A9crit :
>> The following series adds some code to generate legal, locally admin=
istered
>> MAC addresses from OMAP4 CPU Die ID fuse data, and then adds a helpe=
r at
>> net/ethernet taking care of accepting device path / MAC mapping
>> registrations and running a notifier to enforce the requested MAC wh=
en the
>> matching network device turns up.
>
> This looks like something you can solve by user-space entirely. Expos=
e the

That might seem so from a openwrt perspective, where you custom cook th=
e=20
whole userland thing per-device, but it ain't so from a generic rootfs=20
perspective.

Why should Ubuntu, Fedora etc stink up their OSes with Panda-specific=20
workarounds?  And Panda is not the only device with this issue.

-Andy
