From: David Miller <davem@davemloft.net>
Subject: Re: AF_BUS socket address family
Date: Fri, 29 Jun 2012 16:50:23 -0700 (PDT)
Message-ID: <20120629.165023.1605284574408858612.davem@davemloft.net>
References: <20120629231236.GA28593@mail.collabora.co.uk>
	<20120629.161821.948325645333976311.davem@davemloft.net>
	<20120629234230.GA11480@kyllikki.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vincent.sanders@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120629234230.GA11480@kyllikki.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Date: Sat, 30 Jun 2012 00:42:30 +0100

> Basically you are indicating you would be completely opposed to any
> mechanism involving D-Bus IPC and the kernel? 

I would not oppose existing mechanisms, which I do not believe is
impossible to use in your scenerio.

What you really don't get is that packet drops and event losses are
absolutely fundamental.

As long as receivers lack infinite receive queue this will always be
the case.

Multicast operates in non-reliable transports only so that one stuck
or malfunctioning receiver doesn't screw things over for everyone nor
unduly brudon the sender.
