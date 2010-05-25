From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Namespaces and devices
Date: Tue, 25 May 2010 11:56:05 +0200
Message-ID: <AANLkTimp16eLIO7F65t7-hFgXGbVnoEIW3jGhzWTJlYa@mail.gmail.com>
References: <AANLkTimN8IYQBiot2iBB6XV8dtTGRnHQQ6lKLag5plEm@mail.gmail.com>
	 <4BF935F6.2050907@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63710 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932636Ab0EYJ4G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 05:56:06 -0400
Received: by vws9 with SMTP id 9so3137412vws.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 02:56:05 -0700 (PDT)
In-Reply-To: <4BF935F6.2050907@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Sun, May 23, 2010 at 16:04, Daniel Lezcano <daniel.lezcano@free.fr> =
wrote:

> The documentation on this website is a bit out dated. That was the in=
itial
> behavior but was changed as the following.
>
> All the virtual devices are destroyed with the network namespace. The
> destroyable virtual devices are identified when they have the dellink=
 ops
> defined. If you can do the 'ip link del' command on this device, then=
 this
> device type will be destroyed by a netns.

=46air enough, thanks for the explanation.

> About the oops, =A0was the it "kernel panic when using
> netns+bridges+tc(netem)" ?

No, this is a different issue. Probably it got lost in the noise of
the thread, but it is here:
http://thread.gmane.org/gmane.linux.debian.devel.bugs.general/694830/fo=
cus=3D158583
(it is my second mail in that thread)

>> Also, I have read somewhere (now I cannot find it) that supposedly, =
I
>> should be able to move real devices to a netns, but I always get
>> Invalid argument errors.
>
> Yes, that was previously the case with the proof of concept, because =
sysfs
> per namespace was enabled. But this feature is not merged upstream ye=
t (but
> is on the way), so physical devices are not movable across namespaces=
=2E

OK. The plan is for them to return to netns 1 automatically at destroy?

Thanks!
--=20
Mart=EDn Ferrari
