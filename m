From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Note: Atheros ethernet part of compat-wireless too
Date: Wed, 10 Feb 2010 10:16:41 -0800
Message-ID: <43e72e891002101016r754b7504vdb94c110a3c0b608@mail.gmail.com>
References: <43e72e891002020915x572a11fcg57f0b9caf7ed08ea@mail.gmail.com>
	<4B686056.7090405@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ubuntu Kernel Team <kernel-team@lists.ubuntu.com>,
	netdev@vger.kernel.org
To: Tony Espy <espy@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:54939 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755565Ab0BJSRC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 13:17:02 -0500
Received: by pzk17 with SMTP id 17so275474pzk.4
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 10:17:01 -0800 (PST)
In-Reply-To: <4B686056.7090405@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2010 at 9:26 AM, Tony Espy <espy@canonical.com> wrote:
> Luis R. Rodriguez wrote:
>>
>> I wanted to let you know I threw in the Atheros ethernet drivers as
>> part of compat-wireless.
>
> Luis --
>
> Does this include support for the Atheros AR8152 PCI-E fast ethernet
> adapter? =C2=A0Also, what's the lead time for this to land in a "stab=
le" release?

=46igured I'd give you the heads up that the AR8152 is not supported
upstream yet. I just got a tarball of the driver that supports this
and AR8151. Here's our current upstream support status table:

Driver Model-name             vendor:device    Type
atl1c  AR8131                 1969:1063        Gigabit Ethernet
atl1c  AR8132                 1969:1062        Fast Ethernet
atl1   L1                     1969:1048        Gigabit Ethernet
atl2   L2                     1969:2048        Fast Ethernet
atl1e  AR8121/AR8113/AR8114   1969:1026        Gigabit/Fast Ethernet(dr=
iver
                                               check one internal regis=
ter to
                                               see if support gigabit)
atl1c  AR8151(v1.0)           1969:1073        Gigabit Ethernet(not sup=
port
                                               in kernel yet)
atl1c  AR8152(v1.1)           1969:2060        Fast Ethernet(not suppor=
t
                                               in kernel yet)
atl1c  AR8152(v2.0)           1969:2062        Fast Ethernet(not suppor=
t
                                               in kernel yet)

I just updated the PCI ID database accordingly. The driver patches for
atl1c might be easy, will take a quick look. FWIW the tarball I will
be looking at in a few moments is

http://kernel.org/pub/linux/kernel/people/mcgrof/ethernet/AR81Family-li=
nux-v1.0.1.6.tar.bz2

  Luis
