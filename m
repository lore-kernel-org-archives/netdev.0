From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 2/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:22:34 -0500
Message-ID: <1289524954.5167.80.camel@dan>
References: <1289524019.5167.66.camel@dan> <20101111171754.0198e151@nehalam>
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
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@openvz.org>,
	socketcan-core@l
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:52549 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757305Ab0KLBWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:22:47 -0500
In-Reply-To: <20101111171754.0198e151@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Printing different data based on security state seems like an ABI
> nightmare.
> 

I can't remove the data entirely, because that would seriously break the
ABI.  I deliberately kept the same format so as not to break any
userspace programs relying on consistent output - are there really
programs that would break when they read a 0 instead of an address?

-Dan

