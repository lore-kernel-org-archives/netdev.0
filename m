From: jamal <hadi@cyberus.ca>
Subject: Re: [Patch] net: fix build break when CONFIG_NET_CLS_ACT is not set
Date: 29 Mar 2005 16:26:00 -0500
Message-ID: <1112131560.1079.115.camel@jzny.localdomain>
References: <20050329202506.GI22447@hmsendeavour.rdu.redhat.com>
	 <1112130720.1076.112.camel@jzny.localdomain>
	 <20050329211741.GL22447@hmsendeavour.rdu.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050329211741.GL22447@hmsendeavour.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 16:17, Neil Horman wrote:

> No worries.  What exactly is the point of contention on netdev? (I'm not
> currently following that list).  My patch seems to follow the common practice
> for CONFIG_NET_CLS_ACT, in that all references to the action member of the
> appropriate struct are themselves ifdef-ed.

We are trying to kill appearance of any #ifdef CONFIG_NET_CLS_ACT in the
classifiers. The patch you sent is correct except it will introduce
an ifdef that we are trying to kill. The current workaround is to turn
on CONFIG_NET_CLS_ACT in the kernel build.

cheers,
jamal
