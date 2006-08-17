From: Andrey Savochkin <saw@sw.ru>
Subject: Re: [PATCH 3/9] network namespaces: playing and debugging
Date: Thu, 17 Aug 2006 10:28:14 +0400
Message-ID: <20060817102814.A25072@castle.nmd.msu.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060815184843.A2882@castle.nmd.msu.ru> <20060816094641.61190ee9@localhost.localdomain> <m164gs38a3.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:7945 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751149AbWHQG2Q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 02:28:16 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m164gs38a3.fsf@ebiederm.dsl.xmission.com>; from "Eric W. Biederman" on Wed, Aug 16, 2006 at 11:22:28AM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 11:22:28AM -0600, Eric W. Biederman wrote:
> Stephen Hemminger <shemminger@osdl.org> writes:
> 
> > On Tue, 15 Aug 2006 18:48:43 +0400
> > Andrey Savochkin <saw@sw.ru> wrote:
> >
> >> Temporary code to play with network namespaces in the simplest way.
> >> Do
> >>         exec 7< /proc/net/net_ns
> >> in your bash shell and you'll get a brand new network namespace.
> >> There you can, for example, do
> >>         ip link set lo up
> >>         ip addr list
> >>         ip addr add 1.2.3.4 dev lo
> >>         ping -n 1.2.3.4
> >> 
> >> Signed-off-by: Andrey Savochkin <saw@swsoft.com>
> >
> > NACK, new /proc interfaces are not acceptable.
> 
> The rule is that new /proc interfaces that are not process related
> are not acceptable.  If structured right a network namespace can
> arguably be process related.
> 
> I do agree that this interface is pretty ugly there.

This proc interface was a backdoor to play with namespaces without
compiling any user-space programs.

As you wish.
Do you want to have a new clone flag right away?

	Andrey
