From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Namespaces and devices
Date: Tue, 25 May 2010 12:14:38 +0200
Message-ID: <4BFBA30E.4040304@free.fr>
References: <AANLkTimN8IYQBiot2iBB6XV8dtTGRnHQQ6lKLag5plEm@mail.gmail.com>	 <4BF935F6.2050907@free.fr> <AANLkTimp16eLIO7F65t7-hFgXGbVnoEIW3jGhzWTJlYa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:59400 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab0EYKOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 06:14:40 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4PAEdFD017545
	for <netdev@vger.kernel.org>; Tue, 25 May 2010 10:14:39 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4PAEd9p1249398
	for <netdev@vger.kernel.org>; Tue, 25 May 2010 11:14:39 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4PAEcuv017713
	for <netdev@vger.kernel.org>; Tue, 25 May 2010 11:14:39 +0100
In-Reply-To: <AANLkTimp16eLIO7F65t7-hFgXGbVnoEIW3jGhzWTJlYa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2010 11:56 AM, Mart=EDn Ferrari wrote:
> Hi Daniel,
>
> On Sun, May 23, 2010 at 16:04, Daniel Lezcano<daniel.lezcano@free.fr>=
  wrote:
>
>   =20
>> The documentation on this website is a bit out dated. That was the i=
nitial
>> behavior but was changed as the following.
>>
>> All the virtual devices are destroyed with the network namespace. Th=
e
>> destroyable virtual devices are identified when they have the dellin=
k ops
>> defined. If you can do the 'ip link del' command on this device, the=
n this
>> device type will be destroyed by a netns.
>>     =20
> Fair enough, thanks for the explanation.
>   =20

You are welcome ;)

>> About the oops,  was the it "kernel panic when using
>> netns+bridges+tc(netem)" ?
>>     =20
> No, this is a different issue. Probably it got lost in the noise of
> the thread, but it is here:
> http://thread.gmane.org/gmane.linux.debian.devel.bugs.general/694830/=
focus=3D158583
> (it is my second mail in that thread)

Ok, I was able to reproduce it easily. If I have spare time this week, =
I=20
will look at the oops.

>>> Also, I have read somewhere (now I cannot find it) that supposedly,=
 I
>>> should be able to move real devices to a netns, but I always get
>>> Invalid argument errors.
>>>       =20
>> Yes, that was previously the case with the proof of concept, because=
 sysfs
>> per namespace was enabled. But this feature is not merged upstream y=
et (but
>> is on the way), so physical devices are not movable across namespace=
s.
>>     =20
> OK. The plan is for them to return to netns 1 automatically at destro=
y?
>   =20

Yes, this is the plan.

Thanks
   -- Daniel
