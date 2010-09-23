From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Thu, 23 Sep 2010 07:22:06 -0400
Message-ID: <1285240926.5036.7.camel@bigi>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	 <m1hbhgq1v1.fsf@fess.ebiederm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
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
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1hbhgq1v1.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 01:51 -0700, Eric W. Biederman wrote:
> Take advantage of the new abstraction and allow network devices
> to be placed in any network namespace that we have a fd to talk
> about.
> 

So ... why just netdevice? could you allow migration of other
net "items" eg a route table since they are all tagged by
netns?

cheers,
jamal

