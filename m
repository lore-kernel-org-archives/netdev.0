From: kuznet@ms2.inr.ac.ru
Subject: Re: 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 16:40:38 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207301240.QAA03021@sex.inr.ac.ru>
References: <20020730104815.GA22307@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: ahu@ds9a.NL (bert hubert)
In-Reply-To: <20020730104815.GA22307@outpost.ds9a.nl> from "bert hubert" at Jul 30, 2 03:15:01 pm
List-Id: netdev.vger.kernel.org

Hello!

> I'm under the strong impression that 2.4.18 lets userspace see packets with
> incorrect UDP checksums.

How did you get this impression?

> Is this policy?

This is impossible unless requested explicitly with SO_NO_CHECK
or a buggy hardware incorrectly reports checksum is valid.

Alexey
