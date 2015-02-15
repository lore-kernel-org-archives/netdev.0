From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sun, 15 Feb 2015 19:13:56 +0000
Message-ID: <20150215191356.GA14888@casper.infradead.org>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
 <1423901633-53789-4-git-send-email-joestringer@nicira.com>
 <20150214195607.GA30752@casper.infradead.org>
 <CANr6G5x19zc8qK0gtPBFzMD02xMxieFqGpv9-nkKyiZ1MzSUwA@mail.gmail.com>
 <54E0B67A.1030000@6wind.com>
 <CANr6G5yBW5JNMk3qvAuyD+OgtnhV6vg2E-41DO51bVtyeSWSNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46293 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbbBOTOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 14:14:01 -0500
Content-Disposition: inline
In-Reply-To: <CANr6G5yBW5JNMk3qvAuyD+OgtnhV6vg2E-41DO51bVtyeSWSNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/15 at 11:06am, Joe Stringer wrote:
> On 15 February 2015 at 07:08, Nicolas Dichtel <nicolas.dichtel@6wind.=
com> wrote:
> > Le 15/02/2015 05:47, Joe Stringer a =E9crit :
> >> Right, it was more of a general sanity check which is likely unnee=
ded.
> >> I'm not aware of any particular case that this handles.
> >
> > I agree with Thomas. If we fall into this case, it's probably a rea=
l bug ;-)
>=20
> We can BUG_ON(), then.

Let's do a WARN() and just error so we keep the kernel running ;-)
