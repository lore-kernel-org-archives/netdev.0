From: kuznet@ms2.inr.ac.ru
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 23:04:47 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211182004.XAA12908@sex.inr.ac.ru>
References: <20021118195618.GA22603@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20021118195618.GA22603@outpost.ds9a.nl> from "bert hubert" at Nov 18, 2 08:56:19 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I did turn on CONFIG_XFRM_USER, does it conflict with PF_KEY?

Yes, their interaction is still... mmm... not polished.
Build both xfrm_user and af_key as modules and load only one for now.

Alexey
