From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Tue, 5 Feb 2013 18:49:45 +0800
Message-ID: <CAM_iQpXSv7ddFtF53JGu=QdaNgY7c4O9Wuq4PmVRczTBiE_rSg@mail.gmail.com>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
	<20130204081920.00e9f22e@nehalam.linuxnetplumber.net>
	<87lib3gunm.fsf@blp.benpfaff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: blp@cs.stanford.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lib3gunm.fsf@blp.benpfaff.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 5, 2013 at 2:08 PM, Ben Pfaff <blp@cs.stanford.edu> wrote:
> Stephen Hemminger <stephen@networkplumber.org> writes:
>
>> On Tue, 29 Jan 2013 22:15:18 +0800
>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>> Hello, Rusty, Jesse,
>>>
>>> I met an interesting problem when I compile openvswitch module as a
>>> built-in (actually I compile ALL kernel modules as built-in), there is
>>> no /sys/module/openvswitch/ directory created by the kernel in this
>>> case.
>>>
>>> What's worse, the user-space init script thinks openvswitch module is
>>> not loaded by checking the exist of this directory, therefore refuses
>>> to start.
>>
>> Shouldn't the OVS init script be testing for some other API.
>
> I agree that's a bug in the OVS init script.  I will fix it.

Thanks for taking care of it, Ben!
