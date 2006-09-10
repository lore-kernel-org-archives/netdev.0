From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Sun, 10 Sep 2006 21:22:44 +0200
Message-ID: <20060910192244.GB5325@MAIL.13thfloor.at>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609091157.24734.dim@openvz.org> <20060910024709.GA13157@MAIL.13thfloor.at> <200609101145.36207.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>, devel@openvz.org,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:38831 "EHLO
	MAIL.13thfloor.at") by vger.kernel.org with ESMTP id S932548AbWIJTWp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 15:22:45 -0400
To: Dmitry Mishin <dim@openvz.org>
Content-Disposition: inline
In-Reply-To: <200609101145.36207.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 10, 2006 at 11:45:35AM +0400, Dmitry Mishin wrote:
> On Sunday 10 September 2006 06:47, Herbert Poetzl wrote:
> > well, I think it would be best to have both, as
> > they are complementary to some degree, and IMHO
> > both, the full virtualization _and_ the isolation
> > will require a separate namespace to work,   
> [snip]
> > I do not think that folks would want to recompile
> > their kernel just to get a light-weight guest or
> > a fully virtualized one

> In this case light-weight guest will have unnecessary overhead. For
> example, instead of using static pointer, we have to find the required
> common namespace before. 

this is only required at 'bind' time, which makes
a non measurable fraction of the actual connection
usage (unless you keep binding ports over and over
without ever using them)

> And there will be no advantages for such guest over full-featured.

the advantage is in the flexibility, simplicity of
setup and the basically non-existant overhead on
the hot (conenction/transfer) part ...

> > best,
> > Herbert
> >
> > > --
> > > Thanks,
> > > Dmitry.
> 
> -- 
> Thanks,
> Dmitry.
