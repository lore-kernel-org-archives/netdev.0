From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 15:43:27 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301081535460.27551-100000@dns.toxicfilms.tv>
References: <20030108130850.GQ22951@wiggy.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20030108130850.GQ22951@wiggy.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I had no problems listening to the stream, except a gap after about 3mins.
tcpdump showed the client closed the connection, and quickly initiated a
new one. Since then i had 15mins of nonstop playback and it stopped,
similarily to your dump.

The tcpdump is similar to yours, except i do not have traffic class info.
And rarely sack was used.

Is there a ip6 mangling router in your route to the icecast server?

I have been listening on an ip6 enabled host behind my ip6 tunnelling
router to my MAN.

Client: linux-2.4.21-pre1
Router: linux-2.4.20-grsec

I have to go now, i will look into that later.

Regards,
Maciej
