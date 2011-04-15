From: Christian Boltz <netdev-vger-kernel.org-/+gSslFCPOGzQB+pC5nmwQ@public.gmane.org>
Subject: Feature request: "inverted" ping -a (beep on failure)
Date: Fri, 15 Apr 2011 21:35:32 +0200
Message-ID: <201104152135.33171@tux.boltz.de.vu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <netdev.vger.kernel.org>

Hello,

ping -a (beep on ping success) is a quite useful command, but it can be=
=20
annoying.

I'd like to have the exact opposite of it: beep when pinging fails.

I understand that this is slightly difficult because "ping success" is=20
easier to detect (incoming package) than "ping failure" (no incoming=20
package or firewall reject) - my proposal is to have a timeout for ever=
y=20
package (if no reply package comes in) and beep if no reply is seen=20
after the timeout is over.

=46or the timeout, the -W option could be used. The default timeout see=
ms=20
to be 10 seconds, which is OK.

Usecase / why this would be useful for me:
Basically for server monitoring. The exact usecase is that I have rente=
d=20
a "root server" and asked the hoster to exchange a broken harddisk.
With the "inverted" ping -a, it would be easy to notice when they switc=
h=20
off the server to replace the disk.

Please consider this feature for the next version of ping ;-)


(The iputils homepage does not list any bugtracker or similar, therefor=
e=20
I'm asking here.)


Gru=DF

Christian Boltz
--=20
"we will support any library from any repo combined with
any application" is something that NO ONE does.
Or if they do, they are insane, or lying, or both.
[Greg KH in opensuse-factory]
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
