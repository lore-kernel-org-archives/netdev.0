From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback
	down
Date: Sat, 22 Jan 2011 21:42:54 -0800 (PST)
Message-ID: <20110122.214254.226765382.davem@davemloft.net>
References: <20110122.145438.193725532.davem@davemloft.net>
	<901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, maheshkelkar@gmail.com, brian.haley@hp.com,
        stable@kernel.org, lorenzo@google.com
To: stephen.hemminger@vyatta.com
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Sat, 22 Jan 2011 20:41:12 -0800 (PST)

> Having IPv6 remove all addresses when link goes down is fundamentally broken
> that is what the original problem being fixed. For users on servers or using
> Quagga this matters, how do you plan to fix that?

How about in a way that doesn't break stuff?

And it's been beyond proven that people give more of a crap
about disable_ipv6 than the thing you keep claiming is a big deal.

NOBODY other than you even noticed the issue or made a report about
it.

Yet we have people actively complaining about disable_ipv6 being
broken.

So you lose on two counts.  You can't fix things by breaking other
stuff, and your obscure stuff matters less than things people
actually notice being broken.
