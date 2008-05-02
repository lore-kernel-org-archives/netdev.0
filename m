From: "Roland" <devzero@web.de>
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free
Date: Fri, 2 May 2008 18:45:32 +0200
Message-ID: <000701c8ac73$f01d55d0$6400a8c0@bui.materna.com>
References: <005801c8ac37$55e3cb70$6400a8c0@bui.materna.com> <1209743832.22773.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"\"Andrew Morton\"" <akpm@linux-foundation.org>
To: "Soeren Sonnenburg" <kernel@nn7.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:37648 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764382AbYEBQpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 12:45:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i have tried with tun/tap0 device (modprobe tun, tunctl, ifconfig tap0 
1.2.3.4 up, modprobe -r tun -  but i only saw that message twice when remove 
tun module - and the message went away very soon.

i`m curious, but i cannot even reproduce that at the moment.....


----- Original Message ----- 
From: "Soeren Sonnenburg" <kernel@nn7.de>
To: "Roland" <devzero@web.de>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>; ""Andrew 
Morton"" <akpm@linux-foundation.org>
Sent: Friday, May 02, 2008 5:57 PM
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free


> On Fri, 2008-05-02 at 11:31 +0200, Roland wrote:
>> >I am not exactly sure which kernel version Roland (?) is/was using but
>> >from what I can tell this bug is fixed since 2.6.24 (at least). Well I
>> >didn't see it with madwifi nor with the tun devices anymore on any of
>> >the 24.X or 25rc's/25 ...
>>
>> pardon,   2.6.25-git17 in vmware
>
> could you test if this happens with other drivers like tun etc too?
> Maybe the bug re-appeared (I didn't follow 2.6.26 development ...)
>
> Soeren
>
>> >; <netdev@vger.kernel.org>;
>> List:       linux-kernel
>> Subject:    Re: 24rc8: unregister_netdevice: waiting for ... to become 
>> free.
>> From:       Soeren Sonnenburg <kernel () nn7 ! de>
>> Date:       2008-05-02 6:15:43
>> Message-ID: 1209708943.23075.52.camel () localhost
>> [Download message RAW]
>>
>> On Thu, 2008-05-01 at 22:59 -0700, Andrew Morton wrote:
>> > On Fri, 2 May 2008 03:26:28 +0200 "Roland" <devzero@web.de> wrote:
>> >
>> > > i`m also seeing this one, but with pcnet32 - "modprobe -r pcnet32" 
>> > > never
>> > > returns and
>> > >
>> > > "unregister_netdevice: waiting for eth0 to become free. Usage count = 
>> > > 1"
>> > >
>> > > being printed over and over again
>> > >
>> > > lsmod |grep pcnet32 shows
>> > >
>> > > pcnet32            35828    0
>> > > mii                      9344    1    pcnet32
>> > >
>> > > i see stale ssh connection on port 22 and sshd for that session 
>> > > remains
>> > > unkillable process.
>> > >
>> >
>> > here a bug
>> >
>> > >
>> > >
>> > > List:       linux-kernel
>> > > Subject:    Re: 24rc8: unregister_netdevice: waiting for ... to 
>> > > become
>> > > free.
>> > > From:       Soeren Sonnenburg <kernel () nn7 ! de>
>> > > Date:       2008-01-29 8:59:10
>> > > Message-ID: 1201597150.4973.10.camel () localhost
>> > > [Download message RAW]
>> > >
>> > > On Tue, 2008-01-22 at 22:44 -0800, David Miller wrote:
>> > > > From: Soeren Sonnenburg <kernel@nn7.de>
>> > > > Date: Wed, 23 Jan 2008 07:42:21 +0100
>> > > >
>> > > > > Dear all,
>> > > > >
>> > > > > since some 2.6.24rc version I suddenly experience such messages 
>> > > > > on
>> > > > > console when trying to shutdown a vpn connection:
>> > > > >
>> > > > > unregister_netdevice: waiting for tun0 to become free. Usage 
>> > > > > count =
>> > > > > 1
>> > > > >
>> > > > > or when removing an usb wlan dongle (although it was ifconfig 
>> > > > > wlan0
>> > > > > down'd before)
>> > > >
>> > > > Current GIT already has a fix for this, attached below:
>> > >
>> > > hmmhhh, I am still seeing this problem on 2.6.24 with at least with 
>> > > the
>> > > madwifi driver...
>> > >
>> > > Soeren
>> >
>> > there a bug.
>> >
>> >
>> > Let's cc netdev@vger.kernel.org - linux-net is dead, afaik.
>> >
>> > Thanks for reporting all these bugs but please do take much mure care 
>> > over
>> > the cc's.  Be sure to cc every party who was cc'ed on the email to 
>> > which
>> > you're replying.  I restored Soeren.
>>
>> I am not exactly sure which kernel version Roland (?) is/was using but
>> from what I can tell this bug is fixed since 2.6.24 (at least). Well I
>> didn't see it with madwifi nor with the tun devices anymore on any of
>> the 24.X or 25rc's/25 ...
>>
>> Soeren
>> 

