From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [mwifiex/USB8897] Error: Driver 'usb8xxx' is already
 registered, aborting...
Date: Fri, 21 Feb 2014 12:19:27 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430F53B2A485@SC-VEXCH1.marvell.com>
References: <20140221085235.GA2055@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Nishant Sarmukadam <nishants@marvell.com>,
	Frank Huang <frankh@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>,
	Yogesh Powar <yogeshp@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140221085235.GA2055@localhost>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fengguang,

> Greetings,
> 
> I got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> commit 68458dede7e0055198318dcb0318df3b4f419507
> CommitDate: Mon Jan 13 14:46:59 2014 -0500
> 
>     mwifiex: add USB8897 support
> 
> [    6.211307] Error: Driver 'usb8xxx' is already registered, aborting...
> [    6.211307] Error: Driver 'usb8xxx' is already registered, aborting...
> [    6.217261] mwifiex_usb: Driver register failed!
> [    6.217261] mwifiex_usb: Driver register failed!

Thanks for reporting this bug.
I will send the patch to fix it shortly.

Regards,
Bing
