From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] support smc91x on mainstone and devicetree
Date: Tue, 18 Oct 2016 14:14:37 -0400 (EDT)
Message-ID: <20161018.141437.2029098820682032692.davem@davemloft.net>
References: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, daniel@zonque.org,
        haojian.zhuang@gmail.com, jic23@cam.ac.uk, dhowells@redhat.com,
        nico@fluxnic.net, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-am33-list@redhat.com
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Mon, 17 Oct 2016 21:45:28 +0200

> This serie aims at bringing support to mainstone board on a device-tree based
> build, as what is already in place for legacy mainstone.
> 
> The bulk of the mainstone "specific" behavior is that a u16 write doesn't work
> on a address of the form 4*n + 2, while it works on 4*n.
> 
> The legacy workaround was in SMC_outw(), with calls to
> machine_is_mainstone(). These calls don't work with a pxa27x-dt machine type,
> which is used when a generic device-tree pxa27x machine is used to boot the
> mainstone board.
> 
> Therefore, this serie enables the smc91c111 adapter of the mainstone board to
> work on a device-tree build, exaclty as it's been working for years with the
> legacy arch/arm/mach-pxa/mainstone.c definition.
> 
> As a sum up, this extends an existing mechanism to device-tree based pxa platforms.

Series applied, thanks.
