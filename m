From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Thu, 17 Jul 2003 03:28:20 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307162328.DAA12405@dub.inr.ac.ru>
References: <1058394538.5778.17.camel@hades>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, davem@redhat.com, jmorris@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.liljeberg@welho.com (Mika Liljeberg)
In-Reply-To: <1058394538.5778.17.camel@hades> from "Mika Liljeberg" at Jul 17, 2003 01:28:58 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> While I see where you're coming from, I don't really understand what the
> fuss is all about.

The issue definitely does not worth of time already spent for the discussion.

All the fuss is about the fact that this code lived and will live for years.
If we allowed to add small tricks of this kind, it would end up as a full mess.
Each convenience trick must have a logical background.

I have been asked for an opinion, this is my opinion: 6to4 is wrong,
addresses in format of 6over4 are natural, if they are deprecated,
another and even more natural variant is use of link-local format,
fe80::a.b.c.d.

Alexey
