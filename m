From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Mon, 04 Feb 2013 22:08:13 -0800
Message-ID: <87lib3gunm.fsf@blp.benpfaff.org>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
	<20130204081920.00e9f22e@nehalam.linuxnetplumber.net>
Reply-To: blp@cs.stanford.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-smtp-2.Stanford.EDU ([171.64.64.26]:52414 "EHLO
	cs-smtp-2.Stanford.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab3BEGIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 01:08:19 -0500
In-Reply-To: <20130204081920.00e9f22e@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Mon, 4 Feb 2013 08:19:20 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue, 29 Jan 2013 22:15:18 +0800
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> Hello, Rusty, Jesse,
>> 
>> I met an interesting problem when I compile openvswitch module as a
>> built-in (actually I compile ALL kernel modules as built-in), there is
>> no /sys/module/openvswitch/ directory created by the kernel in this
>> case.
>> 
>> What's worse, the user-space init script thinks openvswitch module is
>> not loaded by checking the exist of this directory, therefore refuses
>> to start.
>
> Shouldn't the OVS init script be testing for some other API.

I agree that's a bug in the OVS init script.  I will fix it.
