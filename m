From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2 v2] man - IP_NODEFRAG option for IPv4 socket
Date: Sat, 11 Sep 2010 07:36:15 +0200
Message-ID: <AANLkTi=T0EA_9k13nR9+ivpwUQbugnfkVNQ9ZTZuqY=C@mail.gmail.com>
References: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
 <1276600052-16499-3-git-send-email-jolsa@redhat.com> <AANLkTim4N5rc8Sn_uo5bXsb9vjvKd3GTQD3p-1uApbB8@mail.gmail.com>
 <20100626.095857.137828263.davem@davemloft.net> <20100626191315.GA2076@jolsa.nomadprime.subscribe.loganwifi.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100626191315.GA2076-Wm2NNL2RFAC1BuvyT83C0lrZeV2/+9ztveTR/H6W3zQlvuHqEAARLw@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Jiri

On Sat, Jun 26, 2010 at 9:13 PM, Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Sat, Jun 26, 2010 at 09:58:57AM -0700, David Miller wrote:
>> From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Sat, 26 Jun 2010 15:01:03 +0200
>>
>> >> =A0sent from this socket.
>> >> +.TP
>> >> +.BR IP_NODEFRAG " (since Linux 2.6)"
>> >
>> > here, we'd write the exact version in which the flag is added. It
>> > looks like that might be 2.36, right?
>>
>> It'll show up in 2.6.36
>>
>> I doubt I'll be alive when we make it to 2.36 :-)
>
> :) ok, attaching changed patch

I tweaked that slightly, and applied the below for man-pages-3.27.

Thanks,

Michael

--- a/man7/ip.7
+++ b/man7/ip.7
@@ -399,6 +399,14 @@ The default is 1 which means that multicast
packets don't leave the local
 network unless the user program explicitly requests it.
 Argument is an integer.
 .TP
+.BR IP_NODEFRAG " (since Linux 2.6.36)"
+If enabled (argument is nonzero),
+the reassembly of outgoing packets is disabled in the netfilter layer.
+This option is only valid for
+.B SOCK_RAW
+sockets.
+The argument is an integer.
+.TP
 .BR IP_OPTIONS " (since Linux 2.0)"
 .\" Precisely: 1.3.30
 Set or get the IP options to be sent with every packet from this socke=
t.
--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
