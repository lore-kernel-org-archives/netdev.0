From: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 29 Nov 2004 16:57:25 +0100
Message-ID: <OF773C347F.92E998FA-ONC1256F5B.0056F87D-C1256F5B.0057A78F@de.ibm.com>
References: <Pine.LNX.4.61.0411150735070.10262@hibernia.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.61.0411150735070.10262@hibernia.jakma.org>
To: paul@clubi.ie
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





> Using a socket per interface wont address problem of sending
> quite stale packets when a link > comes back after a long time
> down, AUI. (not a huge problem - but not nice).
>
> Jeff???

Has there been any outcome on the discussion about whether or not
a device driver should drop packets when the cable is disconnected?
It seems that from the zebra point of view, as Paul wrote,
it would be better to not block sockets by queueing up packets
when there is no cable connection.

I do also think that it does not make sense to keep packets in the
queue and then send those packets when the cable is plugged in
again after a possibly long time.
There are protocols like TCP that handle packet loss anyway.

Regards,
Thomas.
