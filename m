From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 23:20:40 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712312316050.28123@fbirervta.pbzchgretzou.qr>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
 <20071231122419.GA13803@does.not.exist> <alpine.LSU.0.999.0712311335210.3761@be1.lrz>
 <20071231144255.GB13803@does.not.exist> <alpine.LSU.0.999.0712311553530.4211@be1.lrz>
 <Pine.LNX.4.64.0712311628330.28123@fbirervta.pbzchgretzou.qr>
 <20071231174302.GA1627@oscar.prima.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bodo Eggert <7eggert@gmx.de>, Adrian Bunk <bunk@kernel.org>,
	devzero@web.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick Mau <mau@oscar.ping.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752646AbXLaWUy@vger.kernel.org>
In-Reply-To: <20071231174302.GA1627@oscar.prima.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Dec 31 2007 18:43, Patrick Mau wrote:
>
>May I ask something that might be obvious for most of the
>development community:
>
>Modules have to be loaded in seperate pages, right ?

That seems to be the case, judging from /proc/modules always ending in 000,
meaning each module is aligned at 0x1000 (4096, a page on i386).

Additionally, it looks like 48% of all kernel symbols (from System.map)
are aligned to 16 byte boundaries (what a waste! ;-))
