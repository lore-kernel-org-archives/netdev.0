From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 07:19:57 -0400
Message-ID: <1285240797.5036.5.camel@bigi>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	 <m1bp7oq1u8.fsf@fess.ebiederm.org>  <4C9B162E.7040201@parallels.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4C9B162E.7040201@parallels.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 12:56 +0400, Pavel Emelyanov wrote:
> On 09/23/2010 12:51 PM, Eric W. Biederman wrote:
> > 
> > Add a system call for creating sockets in a specified network namespace.
> 
> What for?

I can see many uses if my understanding is correct..
ex, from mother namespace:
fdx = open socket at namespace blah
from mother namespace, read/write/poll fdx 
(eg add route with netlink socket)

cheers,
jamal

