From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Wed, 21 Aug 2002 19:55:32 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208211555.TAA15473@sex.inr.ac.ru>
References: <OF6E059725.5F49923C-ONC1256C1C.0054532B@de.ibm.com>
Mime-Version: 1.0
Cc: davem@redhat.com, netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: AHERRMAN@de.ibm.com (Andreas Herrmann)
In-Reply-To: <OF6E059725.5F49923C-ONC1256C1C.0054532B@de.ibm.com> from "Andreas Herrmann" at Aug 21, 2 05:28:52 pm
List-Id: netdev.vger.kernel.org

Hello!

> I removed the config option, added documentation to
> Documentation/networking/netdevices.txt
> and created a new patch for the new net device feature.

One thought: if you have to add a new field to struct netdevice,
it makes lots of sense to move further and to add special method
dev->generate_eui64() instead, which will be initialized
to standard eth_generate_eui64() for normal ethernets
and to something private for your device.

In this way we are guaranteed not to have problems of this kind
in future.

Alexey
