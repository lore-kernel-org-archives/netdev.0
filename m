From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Sat, 09 Sep 2006 21:41:35 -0600
Message-ID: <m14pvggzgw.fsf@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<200609081710.09124.dim@openvz.org>
	<20060908181154.GA8745@MAIL.13thfloor.at>
	<200609091157.24734.dim@openvz.org>
	<20060910024709.GA13157@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Mishin <dim@openvz.org>, Kir Kolyshkin <kir@openvz.org>,
	Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51429 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S965169AbWIJDmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 23:42:47 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060910024709.GA13157@MAIL.13thfloor.at> (Herbert Poetzl's
	message of "Sun, 10 Sep 2006 04:47:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl <herbert@13thfloor.at> writes:

> On Sat, Sep 09, 2006 at 11:57:24AM +0400, Dmitry Mishin wrote:
>> On Friday 08 September 2006 22:11, Herbert Poetzl wrote:
>> > actually the light-weight ip isolation runs perfectly
>> > fine _without_ CAP_NET_ADMIN, as you do not want the
>> > guest to be able to mess with the 'configured' ips at
>> > all (not to speak of interfaces here)
>
>> It was only an example. I'm thinking about how to implement flexible
>> solution, which permits light-weight ip isolation as well as
>> full-fledged netwrok virtualization. Another solution is to split
>> CONFIG_NET_NAMESPACE. Is it good for you?
>
> well, I think it would be best to have both, as
> they are complementary to some degree, and IMHO
> both, the full virtualization _and_ the isolation
> will require a separate namespace to work, I also
> think that limiting the isolation to something
> very simple (like one IP + network or so) would
> be acceptable for a start, because especially
> multi IP or network range checks require a little
> more efford to get them right ...
>
> I do not think that folks would want to recompile
> their kernel just to get a light-weight guest or
> a fully virtualized one

I certainly agree that we are not at a point where a final decision
can be made.  A major piece of that is that a layer 2 approach has
not shown to be without a performance penalty.

A practical question.  Do the IPs assigned to guests ever get used
by anything besides the guest?

Eric
