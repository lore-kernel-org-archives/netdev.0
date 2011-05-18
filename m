From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: How to get backtrace? modprobe -r iwlagn; modprobe iwlagn kills kernel
Date: Thu, 19 May 2011 00:02:55 +0800
Message-ID: <BANLkTinQQwwgPGsX0YSpWJXN5oaatd1Q5g@mail.gmail.com>
References: <201105181637.46164.stevie.trujillo@gmail.com>
	<1305734101_6569@mail4.comsite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stevie Trujillo <stevie.trujillo@gmail.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54966 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655Ab1ERQC4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 12:02:56 -0400
In-Reply-To: <1305734101_6569@mail4.comsite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2011 at 11:55 PM, Milton Miller <miltonm@bga.com> wrote=
:
> On Wed May 18 2011 about 10:37:54 EST, Stevie Trujillo wrote:
>> I'm having some problem getting a backtrace. When I do "modprobe -r
>> iwlagn; modprobe iwlagn" (2.6.38.6 with Intel-1030N) the kernel cras=
hes
>> (sometimes I need to try 2 or 3 times, and sometimes the modprobe -r
>> is the one that crashes).
>>
>> This spams my monitor with several oops/panics before it finally
>> dies. I can only see bottom of the last one, which probably isn't
>> very meaningful. =C2=A0I tried loading netconsole, but I only get on=
e or
>> two lines before it stops sending/printing.
>>
>> I then tried kexec+crashkernel, but I only managed to get a backtrac=
e
>> for the last panic (which I think is just a result of memory corrupt=
ion
>> or something). =C2=A0Finally I tried compiling ramoops into my kerne=
l,
>> but it didn't want to load because of "No such device".
>
> For the kexec+crashkernel, try to retrieve the kernel log buffer:
>

There is a utility in kexec-tools, named vmcore-dmesg, which
is supposed to do this kind of thing.
