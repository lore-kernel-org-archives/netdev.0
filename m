From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: user-to-kernel shared memory with =?UTF-8?Q?net=5Fdevice?=
Date: Tue, 20 Oct 2009 08:47:56 +0200
Message-ID: <3dc384f905c5638e888cf070440c987f@chewa.net>
References: <17cd85320910191428p4ca8bc9lc865babb18f29b1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Chris Ross <chris@compilednetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39436 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbZJTGrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2009 02:47:52 -0400
In-Reply-To: <17cd85320910191428p4ca8bc9lc865babb18f29b1d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 19 Oct 2009 16:28:42 -0500, Chris Ross <chris@compilednetworks.=
com>=0D
wrote:=0D
> All of the mmap examples I can find seem to be for character devices.=
=0D
> Do I need a character device that implements mmap and proxies access=0D
> to the net_device's stats, or is there a way to mmap directly to a=0D
> net_device structure? Also, is this the excepted method when a=0D
> userspace process needs to read large tables from a driver?=0D
=0D
You cannot use mmap() directly on a network device as there are no file=
=0D
descriptors to network devices. In principle, you can still initiate a=0D
memory mapping using a network device ioctl(), but this is probably not=
=0D
such a great idea.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

