From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: [PATCH 3/3] macvlan: allow in-kernel modules to create and
	 manage macvlan devices
Date: Thu, 03 Dec 2009 13:40:53 -0700
Message-ID: <4B17BFE5020000C70007C8C6@soto.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <bridge@lists.linux-foundation.org>,
	<alacrityvm-devel@lists.sourceforge.net>, <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-27 at 23:14 +0100, Arnd Bergmann wrote:
> On Friday 13 November 2009, Patrick Mullaney wrote:
> > 
> > The macvlan driver didn't allow for creation/deletion of devices
> > by other in-kernel modules. This patch provides common routines
> > for both in-kernel and netlink based management. This patch
> > also enables macvlan device support for gro for lower level
> > devices that support gro.
> 
> I wonder if doing this way round is a good idea, why don't
> you just use netlink to set up the endpoint device like
> the current macvlan and macvtap do? I think doing it consistently
> for all backends would be a significant advantage.

sorry for the late response - I'm thinking about re-implementing
this along the lines that you are talking about. Especially in light
of your new configuration options. The reason(probably short sighted)
for the previous approach was that the creation step was already being
handled in our venet driver(but it doesn't have to be).

Thanks for the suggestion.
Patrick

> 
> 	Arnd <><

