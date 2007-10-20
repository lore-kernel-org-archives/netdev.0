From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Sat, 20 Oct 2007 06:40:02 +0300
Message-ID: <200710200640.02012.a1426z@gawab.com>
References: <200710120031.42805.a1426z@gawab.com> <47168EA1.1080300@tmr.com> <471699A0.3060303@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <471699A0.3060303@tmr.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Davidsen wrote:
> Bill Davidsen wrote:
> >>>> If not, then shouldn't the filter table be obsoleted to avoid
> >>>> confusion?
> >>>
> >>> That would probably confuse people. Just don't use it if you don't
> >>> need to.
> >
> > That is a most practical suggestion.
> >
> >> The problem is that people think they are safe with the filter table,
> >> when in fact they need the prerouting chain to seal things.  Right now
> >> this is only possible in the mangle table.
> >
> > I'm not sure what you think is unsafe about using the filter table, and
> > the order of evaluation issues certainly seem to suggest that some
> > actions would take a major rethink at least. Perhaps you could avoid
> > breaking all of the setups which currently work, rather than force
> > everyone to do things differently because you feel that your way is
> > better.
>
> It was my intention to suggest that unintentional breakage of existing
> setups should be avoided, not that removing the filter table was some
> evil plot. ;-)
> On rereading my original post I failed to make that clear, please take
> it as intended.

Sure, the idea was to mark the filter table obsolete as to make people start 
using the mangle table to do their filtering for new setups.  The filter 
table would then still be available for legacy/special setups.  But this 
would only be possible if we at least ported the REJECT target to mangle.


Thanks!

--
Al

