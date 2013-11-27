From: Ryan Whelan <rcwhelan@gmail.com>
Subject: Re: Kernel Panic in IPv6 vxlan
Date: Wed, 27 Nov 2013 09:44:03 -0500
Message-ID: <CAM3m09SXK1VDv+0JAQfpxjO2G=pJZzVEPNz=WbmXPQAjhALhyA@mail.gmail.com>
References: <CAM3m09T2tuFCMjzdJq7AVBDnPeK0kVKt51JXsE954cHO6u_u2A@mail.gmail.com>
	<5295AC7A.8020502@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:56417 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab3K0OoF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 09:44:05 -0500
Received: by mail-la0-f53.google.com with SMTP id ea20so5228064lab.40
        for <netdev@vger.kernel.org>; Wed, 27 Nov 2013 06:44:03 -0800 (PST)
In-Reply-To: <5295AC7A.8020502@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That isn't required with IPv4- if you don't specify an interface with
IPv4, it looks like the system will route the multicast traffic via
routing.  Is this not an option with IPv6?  I might be
misunderstanding something?

thanks

On Wed, Nov 27, 2013 at 3:25 AM, Fan Du <fan.du@windriver.com> wrote:
> Hallo,
>
>
> On 2013=C4=EA11=D4=C227=C8=D5 05:41, Ryan Whelan wrote:
>>
>> I'm not sure if this is the right place to report this- please corre=
ct
>> me if I'm mistaken.
>>
>> When creating a vxlan interface with an IPv6 multicast group but not
>> specifying an underlying device, the kernel panics when the vxlan
>> interface is brought up.  This doesn't happen with an IPv4 multicast
>> group.  Linux 3.12.1 x86_64
>>
>> `ip link add vxlan0 type vxlan id 42 group ff0e::110`
>
>
> You forgot to attach vxlan0 to a physical netdev ;) try:
>
> ip link add vxlan0 type vxlan id 42 group ff0e::110 dev ethX
>
> This will work anyway.
>
> --
> =B8=A1=B3=C1=CB=E6=C0=CB=D6=BB=BC=C7=BD=F1=B3=AF=D0=A6
>
> --fan fan
