From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Mon, 4 Feb 2013 08:19:20 -0800
Message-ID: <20130204081920.00e9f22e@nehalam.linuxnetplumber.net>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Jan 2013 22:15:18 +0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Hello, Rusty, Jesse,
> 
> I met an interesting problem when I compile openvswitch module as a
> built-in (actually I compile ALL kernel modules as built-in), there is
> no /sys/module/openvswitch/ directory created by the kernel in this
> case.
> 
> What's worse, the user-space init script thinks openvswitch module is
> not loaded by checking the exist of this directory, therefore refuses
> to start.

Shouldn't the OVS init script be testing for some other API.
