From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit userspace
Date: Fri, 28 Nov 2014 15:35:28 +0800
Message-ID: <CAJFZqHyHaD7+6fqjmsVh_JeDrto5SmN2D6rZkjWa3axfM0+AiA@mail.gmail.com>
References: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
	<54781F55.5040603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: FengYu LeiDian <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:36599 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaK1Hf3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 02:35:29 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so4352136qcq.25
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 23:35:28 -0800 (PST)
In-Reply-To: <54781F55.5040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 28, 2014 at 3:08 PM, FengYu LeiDian
<fengyuleidian0615@gmail.com> wrote:
> =D3=DA 2014=C4=EA11=D4=C228=C8=D5 14:58, roy.qing.li@gmail.com =D0=B4=
=B5=C0:
>> From: Li RongQing<roy.qing.li@gmail.com>
>>
>> The size of struct xfrm_userpolicy_info is 168 bytes for 64bit kerne=
l, and
>> 164 bytes for 32bit userspace because of the different alignment. an=
d lead
>> to "ip xfrm" be unable to work.
>>
>> add a pad in struct xfrm_userpolicy_info, and enable it by set
>> KERNEL_64_USERSPACE_32 to y
>
>
> It's not easy to fix it like this.
>
> Refer:
> http://marc.info/?l=3Dlinux-netdev&m=3D139280143513650&w=3D2
> http://thread.gmane.org/gmane.linux.network/157118/focus=3D157122
>

is it be practical to find all structures which has the issue for
64bit kernel and 32 bit
userspace, and conditionally add a pad for them

-Roy
