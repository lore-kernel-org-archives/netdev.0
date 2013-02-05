From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Tue, 5 Feb 2013 22:28:27 +0800
Message-ID: <CAM_iQpWOKTrG2_8NVTd73AvLt3mcYGLisSTdHprStQ=dABSVgQ@mail.gmail.com>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
	<87boc0liug.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87boc0liug.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 4, 2013 at 1:59 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>> Hello, Rusty, Jesse,
>>
>> I met an interesting problem when I compile openvswitch module as a
>> built-in (actually I compile ALL kernel modules as built-in), there is
>> no /sys/module/openvswitch/ directory created by the kernel in this
>> case.
> ...
>> What's worse, the user-space init script thinks openvswitch module is
>> not loaded by checking the exist of this directory, therefore refuses
>> to start.
>
> We only know built-in "modules" exist if we see a parameter or version
> which mention them.  Looking for /sys/module/openvswitch/ is almost as
> flawed as looking in /proc/modules.

You are right. Ben will fix the openvswitch init script.

Thanks for your reply!
