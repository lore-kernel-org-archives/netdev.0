From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Linux 2.6.38-rc4 (hysdn: BUG)
Date: Wed, 9 Feb 2011 14:00:48 -0800
Message-ID: <AANLkTikyPaFi96zrEbszFZzeB8UA-NWkjWFu2d_7X=EF@mail.gmail.com>
References: <20110209092419.2b335697.randy.dunlap@oracle.com>
 <AANLkTimUg8Dm9mZotubcgPHz8_at=_hnbeWUo-LfSALp@mail.gmail.com>
 <20110209132529.76927f5f.randy.dunlap@oracle.com> <20110209.135751.112605587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn@linux-pingi.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110209.135751.112605587.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 9, 2011 at 1:57 PM, David Miller <davem@davemloft.net> wrote:
>
> I propose we just kill this stuff off completely.
>
> I note that there is code in other places of this driver that copy
> the read-only revision string into a local string buffer then pass
> it into the hysdn_getrev() function, it just doesn't happen in this
> one spot.
>
> Anyways, I think I'll fix this like so:

Ack from me. Removing terminally buggy and pointless code is certainly
better than trying to fix it up. No amount of lipstick will make that
pig look good.

                      Linus
