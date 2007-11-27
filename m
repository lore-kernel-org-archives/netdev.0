From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: RE: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 01:28:43 -0800 (PST)
Message-ID: <716567.82573.qm@web51408.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51408.mail.re2.yahoo.com ([206.190.38.187]:33151 "HELO
	web51408.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758315AbXK0J2o convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 04:28:44 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek,
iptables chains (this is what I think you are referring to) are not the=
 issue. This
is about the qdisc that sits immediately over the device driver and dec=
ides the
order waiting packets are sent over the line/air/carrier pigeon/... .
My suspicion is that skb->priority used to be set to a value that deriv=
ed from the
TOS bits. Then something changed and nobody noticed.
--=20
=20
Regards
=20
       Joerg
=20


----- Urspr=FCngliche Mail ----
Von: Jarek Poplawski <jarkao2@o2.pl>
An: Jarek Poplawski <jarkao2@o2.pl>
CC: Joerg Pommnitz <pommnitz@yahoo.com>; netdev@vger.kernel.org; OLSR d=
iscussion and development <olsr-users@olsr.org>
Gesendet: Dienstag, den 27. November 2007, 07:46:04 Uhr
Betreff: Re: Does tc-prio really work as advertised?

On 26-11-2007 23:25, Jarek Poplawski wrote:
=2E..
> Are you doing this on the same box? I was tracing this long time ago =
 too, and, if
> I didn't miss something, it was about the place! So, as I recall  (af=
ter finding
> some old message) this TOS is considered only for packets going  thro=
ugh the FORWARD
> chain. (But, I haven't checked this at all now, so "no  complaints"..=
=2E)

=2E..Too exactly! Iptables aren't needed for this, so "going through
the forward." should be enough...

Jarek P.






      Machen Sie Yahoo! zu Ihrer Startseite. Los geht's:=20
http://de.yahoo.com/set
