From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Sun, 6 Feb 2011 10:09:57 -0800
Message-ID: <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<201101231845.20505.maciej.rutecki@gmail.com>
	<AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com>
	<201101241625.45367.maciej.rutecki@gmail.com>
	<loom.20110205T163216-459@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: chriss <mail_to_chriss@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64591 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab1BFSJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 13:09:57 -0500
Received: by iwn9 with SMTP id 9so3885680iwn.19
        for <netdev@vger.kernel.org>; Sun, 06 Feb 2011 10:09:57 -0800 (PST)
In-Reply-To: <loom.20110205T163216-459@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 5, 2011 at 7:34 AM, chriss <mail_to_chriss@gmx.net> wrote:
> Maciej Rutecki <maciej.rutecki <at> gmail.com> writes:
>
>>
>> On niedziela, 23 stycznia 2011 o 22:29:02 Jesse Gross wrote:
>> > On Sun, Jan 23, 2011 at 9:45 AM, Maciej Rutecki
>> >
>> > <maciej.rutecki <at> gmail.com> wrote:
>> > > I created a Bugzilla entry at
>> > > https://bugzilla.kernel.org/show_bug.cgi?id=27432
>> > > for your bug report, please add your address to the CC list in there,
>> > > thanks!
>> >
>> > This isn't a bug - the change resolved behavior that varied depending
>> > on what NIC was in use.
>>
>> Thanks for the update. Closing.
>>
>> Regards
>
>
> Hi
>
> How am i supposed to put my eth to a bridge and have a seprate vlan besides that
> bridge?

You should either attached a bridge to a vlan device or stack a vlan
device on the bridge port depending on what you are trying to achieve.

The bridge handler takes all packets of the device that it is attached
to, so having a vlan also attached to the same device will not work.
You may get different results on older kernels depending on what NIC
you were using but that was a bug.
