From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 07:57:00 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204230749260.7811-100000@simon.ratbox.org>
References: <20020423.035453.96160070.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020423.035453.96160070.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Okay, tried it this time.  It worked for a short period of time, as I
could ping the default gateway.  When I tried to ping it from another
host, that is when it decided it would go dead.  This time, it did not go
crazy and lock the system up at least.  I tried at both full and half
duplex, with the same experience.

Regards,

Aaron



On Tue, 23 Apr 2002, David S. Miller wrote:

>    From: Aaron Sethman <androsyn@ratbox.org>
>    Date: Tue, 23 Apr 2002 07:19:25 -0400 (EDT)
>
>    I'm *certain* this is a switch, albeit a cheap, unmanaged one, I've got
>    other devices hanging off of it that are just happy at 100MB/full duplex
>    right now. Also I am not forcing it to full duplex, this is what it is
>    trying to do on its own.
>
> It means it cannot negotiate this with the switch for some reason.
>
> Does trying to force full duplex using 'ethtool' have any
> effect?
>

