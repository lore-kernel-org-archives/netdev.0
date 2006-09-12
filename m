From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [RFC] network namespaces
Date: Tue, 12 Sep 2006 11:38:16 +0400
Message-ID: <200609121138.17403.dim@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609111910.31624.dim@openvz.org> <m1zmd57ogg.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:50067 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S964931AbWILHjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 03:39:17 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1zmd57ogg.fsf_-_@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, dont' understand your proposal correctly from the previous talk. :)
But...

On Tuesday 12 September 2006 07:28, Eric W. Biederman wrote:
> Do you have some concrete arguments against the proposal?
Yes, I have. I think it is unnecessary complication. This complication will 
followed in additional bugs. Especially if we'll accept rules creation in 
userspace. Why we need complex solution, if there are only two approaches to  
socket bound - isolation and virtualization? These approaches could co-exist 
without hooks. Or you probably have thoughts about other ways?

-- 
Thanks,
Dmitry.
