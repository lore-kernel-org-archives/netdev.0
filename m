From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: AF_BUS socket address family
Date: Fri, 06 Jul 2012 12:27:33 -0600
Message-ID: <4FF72E15.1010703@genband.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <20120629.153656.1141845894730637434.davem@davemloft.net> <20120629231236.GA28593@mail.collabora.co.uk> <alpine.LNX.2.01.1207052242450.2202@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1207052242450.2202@frira.zrqbmnf.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Saturday 2012-06-30 01:12, Vincent Sanders wrote:
>> Firstly it is intended is an interprocess mechanism and not to rely on
>> a configured IP system, indeed one of its primary usages is to
>> provide mechanism for various tools to set up IP networking.
> Using IP as a localhost IPC is not uncommon (independent of
> software preferring AF_UNIX, if so available). Distro boot
> scripts have been running `ip addr add ::1/128 dev lo`
> all these years along.
>
> And now we suddently need a DBUS program just to configure
> IP-based localhost IPC? I can see the flaw in that.
>

I haven't tried it in a while but it used to be that you couldn't use IP 
multicast on the "lo" device.  Has that been fixed?

Chris
