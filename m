From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Wed, 21 Oct 2009 09:48:18 +0200
Message-ID: <b2cc26e40910210048y43bdb604pcd356376a93c41e@mail.gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>
	 <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
	 <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>
	 <4ADEB752.50103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:57090 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbZJUHsO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 03:48:14 -0400
Received: by yxe17 with SMTP id 17so5806018yxe.33
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 00:48:18 -0700 (PDT)
In-Reply-To: <4ADEB752.50103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2009 at 9:25 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Olaf van der Spek a =C3=A9crit :
>> On Thu, Oct 15, 2009 at 10:59 AM, Olaf van der Spek
>> <olafvdspek@gmail.com> wrote:
>>> On Sat, Oct 10, 2009 at 3:01 PM, Olaf van der Spek <olafvdspek@gmai=
l.com> wrote:
>>>> Hi,
>>>>
>>>> I'm forwarding Debian feature request #520668.
>>>>
>>>> Could syn cookies be enabled by default?
>>>>
>>>> AFAIK syn cookies only get send when the half-open TCP connection
>>>> queue is full. So stuff like window scaling should work fine in no=
rmal
>>>> situations.
>>>>
>>>> Speaking of which:
>>>> When the half-open TCP connection queue is full and syn cookies ar=
e
>>>> enabled, you get a message like "kernel: possible SYN flooding on =
port
>>>> 2710. Sending cookies."
>>>> However when syn cookies are disabled, you don't get any message (=
in
>>>> kern.log), although connections to your server are timing out.
>>>> Could such a message be added?
>>>> Maybe with a suggestion to increase the size of that queue or to
>>>> enable syn cookies.
>>>>
>>>> Greetings,
>>>>
>>>> Olaf
>>>>
>>>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D520668
>>>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D520667
>>>> https://bugs.launchpad.net/ubuntu/+bug/57091
>>>>
>>> Somebody?
>>
>> Anybody?
>
> This is a user selectable setting. What's wrong with /etc/sysctl.conf=
 ?

It requires user action...
Often you notice cookies are disabled only after a service becomes unre=
achable.
What's wrong with improving defaults?
Don't forget the missing log entries.

Olaf
