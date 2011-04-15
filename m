From: Christian Boltz <netdev-vger-kernel.org-/+gSslFCPOGzQB+pC5nmwQ@public.gmane.org>
Subject: Re: Feature request: "inverted" ping -a (beep on failure)
Date: Fri, 15 Apr 2011 22:11:45 +0200
Message-ID: <201104152211.46180@tux.boltz.de.vu>
References: <201104152135.33171@tux.boltz.de.vu> <20110415124937.6e746646.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110415124937.6e746646.rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Sender: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <netdev.vger.kernel.org>

Hello,

Am Freitag, 15. April 2011 schrieb Randy Dunlap:
> On Fri, 15 Apr 2011 21:35:32 +0200 Christian Boltz wrote:
> > I'd like to have the exact opposite of it: beep when pinging fails.
[...]
> Couldn't you look for exit code (status) 1 and then do a bell/beep
> (or play a sound file :)?

That would require that I know in advance when exactly the server is=20
unreachable - but in this case, I wouldn't need to ping it ;-)

To have this working, ping would need an option "exit on error", which=20
it doesn't have AFAIK.

A workaround is to run ping -c1 in a loop:

while true ; do
    ping -c1 $server || beep
    sleep 1
done

but I'd prefer to have something like this directly in ping ;-)

> Or do you want ping to beep and then continue running?

Yes, that's exactly what I want.


Gru=DF

Christian Boltz
--=20
> Ich moechte gern einige User die ihre Mails ueber einen Mailserver=20
> (sendmail bevorzugt, postfix auch moeglich) scannen.
Daf=FCr reicht ein Kopierer. Hosen runter, User draufsetzen und "Copy"=20
dr=FCcken!   [> Ralf Thomas und Sandy Drobic in suse-linux]
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
