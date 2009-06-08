From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2] netdev: smsc911x: allow building
	on Blackfin systems
Date: Mon, 8 Jun 2009 17:50:32 -0400
Message-ID: <8bd0f97a0906081450s6b471d30p56d86e31ba708730@mail.gmail.com>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
	 <OF063E0F2B.DD999013-ON802575CF.006B45BD-802575CF.006BB3F8@smsc.com>
	 <20090608.143710.83724675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com, uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:21237 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210AbZFHVub convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:50:31 -0400
Received: by qw-out-2122.google.com with SMTP id 5so2213461qwd.37
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2009 14:50:33 -0700 (PDT)
In-Reply-To: <20090608.143710.83724675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 8, 2009 at 17:37, David Miller wrote:
> From: Steve.Glendinning@smsc.com
>> You're right, there's nothing "special" about ARM | SUPERH other tha=
n they
>> cover all the in-tree platforms using smsc911x. =C2=A0The aim was to=
 hide this
>> option from menuconfig on x86 etc, where this device is extremely un=
likely
>> to be found. =C2=A0Maybe there's a better way of doing this?
>
> I sincerely doubt keeping this out of x86's menuconfig so important,
> really.

and desktop systems' menuconfig is so big that i dont think one more
driver will make a difference

> So many devices are available for powerpc and sparc64 that will never
> appear there, however those drivers now get build validated on those
> platforms and it's therefore a net-win.

i run randconfigs nightly ... it's neat the kind of unlikely build bugs=
 you find
-mike
