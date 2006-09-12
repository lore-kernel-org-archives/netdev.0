From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Mon, 11 Sep 2006 21:26:52 -0600
Message-ID: <m11wqh9343.fsf_-_@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<200609091157.24734.dim@openvz.org>
	<20060910024709.GA13157@MAIL.13thfloor.at>
	<200609101145.36207.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:62364 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S964821AbWILD2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 23:28:06 -0400
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200609101145.36207.dim@openvz.org> (Dmitry Mishin's message of
	"Sun, 10 Sep 2006 11:45:35 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Sunday 10 September 2006 06:47, Herbert Poetzl wrote:
>> well, I think it would be best to have both, as
>> they are complementary to some degree, and IMHO
>> both, the full virtualization _and_ the isolation
>> will require a separate namespace to work,   
> [snip]
>> I do not think that folks would want to recompile
>> their kernel just to get a light-weight guest or
>> a fully virtualized one
> In this case light-weight guest will have unnecessary overhead.
> For example, instead of using static pointer, we have to find the required 
> common namespace before. And there will be no advantages for such guest over 
> full-featured.

Dmitry that just isn't true if implemented properly.  

Eric
