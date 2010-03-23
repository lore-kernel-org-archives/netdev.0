From: James Chapman <james@jchapman.plus.com>
Subject: Re: [PATCH 00/12] l2tp: Introduce L2TPv3 support
Date: Tue, 23 Mar 2010 10:19:03 +0000
Message-ID: <2f9409cb1003230319u799ef2e4l583f4f667ffa0169@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:45876 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0CWKTG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 06:19:06 -0400
Received: by fxm5 with SMTP id 5so2656349fxm.29
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 03:19:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> > Doesn't even build:
> >
> > net/l2tp/l2tp_ip.c:600: error: =91compat_udp_setsockopt=92 undeclar=
ed here (not in a function)
> > net/l2tp/l2tp_ip.c:601: error: =91compat_udp_getsockopt=92 undeclar=
ed here (not in a function)
> >
> > You can't do this like this, as the header providing these
> > declarations is private to net/ipv4/

Oops, no-one built this with CONFIG_COMPAT when testing. Will fix.

> > Respin your entire patch set once you've resolved this and
> > also please fix these fundamental whitespace errors emitted
> > by git when I apply your patches:

scripts/checkpatch.pl didn't pick these up. Is there a recommended way
to find these in the future? I'm using stg to manage these patches.

> > Applying: l2tp: Relocate pppol2tp driver to new net/l2tp directory
> > Applying: l2tp: Split pppol2tp driver into separate l2tp and ppp pa=
rts
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:118: new b=
lank line at EOF.
> > +
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:133: new b=
lank line at EOF.
> > +
> > warning: 2 lines add whitespace errors.
> > Applying: ppp: Add ppp_dev_name() exported function
> > Applying: l2tp: Add ppp device name to L2TP ppp session data
> > Applying: l2tp: Add L2TPv3 protocol support
> > Applying: l2tp: Update PPP-over-L2TP driver to work over L2TPv3
> > Applying: l2tp: Add L2TPv3 IP encapsulation (no UDP) support
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:61: new bl=
ank line at EOF.
> > +
> > warning: 1 line adds whitespace errors.
> > Applying: netlink: Export genl_lock() API for use by modules
> > Applying: l2tp: Add netlink control API for L2TP
> > Applying: l2tp: Add L2TP ethernet pseudowire support
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:25: space =
before tab in indent.
> > =A0 =A0 =A0used as a control protocol and for data encapsulation to=
 set
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:26: space =
before tab in indent.
> > =A0 =A0 =A0up Pseudowires for transporting layer 2 Packet Data Unit=
s
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:27: space =
before tab in indent.
> > =A0 =A0 =A0across an IP network [RFC3931].
> > /home/davem/src/GIT/net-next-2.6/.git/rebase-apply/patch:12: new bl=
ank line at EOF.
> > +
> > warning: 4 lines add whitespace errors.
> > Applying: l2tp: Add support for static unmanaged L2TPv3 tunnels
> > Applying: l2tp: Update documentation
> >
> > Thanks.

I'm out the office this week. I'll fix the above (unless others beat me
to it) and resend as soon as I'm back.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
