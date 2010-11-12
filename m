From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 3/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 10:14:21 -0500
Message-ID: <1289574861.3090.290.camel@Dan>
References: <1289524023.5167.67.camel@dan>
	 <1289574706.2247.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	James Morris <jmorris@namei.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Li Zefan <lizf@cn.fujitsu.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Eme
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:59029 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932382Ab0KLPOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 10:14:23 -0500
In-Reply-To: <1289574706.2247.4.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Similarly for other formats that you want to make conditional on
> CAP_NET_ADMIN.

I wanted to avoid a %p output of "(null)" in case userspace tools
couldn't handle that, but I agree this is much nicer looking.  I'm
currently putting together a new format specifier instead, as per the
suggestions of Eric and David.

-Dan

