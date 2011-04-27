From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 27 Apr 2011 06:32:51 +0200
Message-ID: <1303878771.2699.44.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303878240.2699.41.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 avril 2011 =C3=A0 06:24 +0200, Eric Dumazet a =C3=A9crit=
 :

> We had similar reports in the past that disappeared when adding
> "slab_nomerge" to boot parameters. We suspect a memory corruption fro=
m
> another part of kernel on 64bytes kmemcache objects.
>=20
> In 2.6.37, inetpeer code uses 64bytes objects. Using slab_nomerge and
> SLUB allocator (as you already do), makes sure inetpeer kmemcache won=
t
> be shared by other 64bytes objects in kernel.
>=20

Of course, the right option name is slub_nomerge

vi +2293 Documentation/kernel-parameters.txt

        slub_nomerge    [MM, SLUB]
                        Disable merging of slabs with similar size. May=
 be
                        necessary if there is some reason to distinguis=
h
                        allocs to different slabs. Debug options disabl=
e
                        merging on their own.
                        For more information see Documentation/vm/slub.=
txt.
