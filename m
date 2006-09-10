From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Sun, 10 Sep 2006 11:45:35 +0400
Message-ID: <200609101145.36207.dim@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609091157.24734.dim@openvz.org> <20060910024709.GA13157@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kirill Korotaev <dev@sw.ru>, devel@openvz.org,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:29213 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1750740AbWIJHqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2006 03:46:35 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060910024709.GA13157@MAIL.13thfloor.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 September 2006 06:47, Herbert Poetzl wrote:
> well, I think it would be best to have both, as
> they are complementary to some degree, and IMHO
> both, the full virtualization _and_ the isolation
> will require a separate namespace to work,   
[snip]
> I do not think that folks would want to recompile
> their kernel just to get a light-weight guest or
> a fully virtualized one
In this case light-weight guest will have unnecessary overhead.
For example, instead of using static pointer, we have to find the required 
common namespace before. And there will be no advantages for such guest over 
full-featured.

>
> best,
> Herbert
>
> > --
> > Thanks,
> > Dmitry.

-- 
Thanks,
Dmitry.
