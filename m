From: kuznet@ms2.inr.ac.ru
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 01:00:29 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210132100.BAA09316@sex.inr.ac.ru>
References: <Pine.GSO.4.30.0210131610010.26803-100000@shell.cyberus.ca>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca (jamal)
In-Reply-To: <Pine.GSO.4.30.0210131610010.26803-100000@shell.cyberus.ca> from "jamal" at Oct 13, 2 04:30:34 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> status. At the moment the only status is IFF_RUNNING in the ifi_flags.
> So the question was could we use ifi_change to send the other pieces of
> info

No, of course. The question is really strange. :-)

> If not, could we take advantage of that pad in the ifinfomsg?

ifi_flags has lots of spare space, 16 bits.

And the second: IFF_RUNNING seems to be enough. Their "dormant" and
"lowerLayerDown" are logically undistinuishable.

Alexey
