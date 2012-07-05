From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: AF_BUS socket address family
Date: Thu, 5 Jul 2012 23:06:21 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1207052242450.2202@frira.zrqbmnf.qr>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <20120629.153656.1141845894730637434.davem@davemloft.net> <20120629231236.GA28593@mail.collabora.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120629231236.GA28593@mail.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2012-06-30 01:12, Vincent Sanders wrote:
>
>Firstly it is intended is an interprocess mechanism and not to rely on
>a configured IP system, indeed one of its primary usages is to
>provide mechanism for various tools to set up IP networking.

Using IP as a localhost IPC is not uncommon (independent of
software preferring AF_UNIX, if so available). Distro boot
scripts have been running `ip addr add ::1/128 dev lo`
all these years along.

And now we suddently need a DBUS program just to configure
IP-based localhost IPC? I can see the flaw in that.
