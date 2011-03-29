From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: zero copy for relay server
Date: Tue, 29 Mar 2011 19:28:51 +0800
Message-ID: <AANLkTi=GYxOP19HwdD0X33hX-Ku12oxwcX5=-okC9Let@mail.gmail.com>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
 <1301331138.3182.43.camel@edumazet-laptop> <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
 <1301337257.2506.8.camel@edumazet-laptop> <AANLkTimWf4kyi4HJFToXP=HH==hQgObQsHYyRfrSe0FS@mail.gmail.com>
 <1301372590.2506.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Viral Mehta <Viral.Mehta@lntinfotech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36875 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782Ab1C2L3L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 07:29:11 -0400
Received: by iwn34 with SMTP id 34so65325iwn.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 04:29:11 -0700 (PDT)
In-Reply-To: <1301372590.2506.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 12:23 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 29 mars 2011 =E0 10:00 +0800, Changli Gao a =E9crit :
>> On Tue, Mar 29, 2011 at 2:34 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>
>> I think he concerns the overhead of system calls. In order to omit a
>> system call, I think you can implement sth. like this:
>>
>> splice2(infd, outfd, pipefd, ...)
>>
>
> Yes, but given no numbers are given, and no code yet written, I ask t=
he
> question.
>
> Giving 4 file descriptors to a single syscall sounds convoluted.
>

It is a waste of fd using pipe buffer with two fds. In fact, I had
ever posted a patch, which extends pipe(2) to return a O_RDWR fd when
NULL is passed in.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
