From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit
 on setup
Date: Wed, 30 Mar 2016 03:02:16 +0200
Message-ID: <20160330010216.GG31182@lunn.ch>
References: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org>
 <1459249908-4556-2-git-send-email-patrick@puiterwijk.org>
 <87fuv9fe39.fsf@ketchup.mtl.sfl>
 <20160329162825.GC4690@lunn.ch>
 <87wpolgluy.fsf@ketchup.mtl.sfl>
 <CAJweMdYPfk7v0VVZoKW3+ZFsKD=6ja-yCo0jjwygTwYE3D30fQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>, davem@davemloft.net,
	netdev@vger.kernel.org, Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>
To: Patrick Uiterwijk <patrick@puiterwijk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42393 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995AbcC3BCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 21:02:30 -0400
Content-Disposition: inline
In-Reply-To: <CAJweMdYPfk7v0VVZoKW3+ZFsKD=6ja-yCo0jjwygTwYE3D30fQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 12:58:04AM +0000, Patrick Uiterwijk wrote:
> Hi Vivien,
> 
> On Tue, Mar 29, 2016 at 6:49 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
> > Hi Andrew, Patrick,
> >
> > Andrew Lunn <andrew@lunn.ch> writes:
> >
> >> On Tue, Mar 29, 2016 at 12:23:06PM -0400, Vivien Didelot wrote:
> >>> Hi Patrick,
> >>>
> >>> Two comments below.
> >>>
> >>> Patrick Uiterwijk <patrick@puiterwijk.org> writes:
> >>>
> >>> > +static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
> >>>
> >>> Since this function assumes the SMI lock is already held, its name
> >>> should be prefixed with _ by convention (_mv88e6xxx_power_on_serdes).
> >>
> >> We decided to drop at, since nearly everything would end up with a _
> >> prefix. The assert_smi_lock() should find any missing locks, and
> >> lockdep/deadlocks will make it clear when the lock is taken twice.
> >
> > OK, I didn't know that. This makes sense. There is no need to respin a
> > v3 only for my previous &= comment then.
> 
> Does that mean the merger will fix this up?
> Or that I'll roll a v3 when I get a reviewed-by for the second patch?

Hi Patrick

Role a v3, and you can add

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

as well as Viviens for patch #1.

     Andrew
