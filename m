From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v5 3/3] net: reserve ports for applications using fixed port numbers
Date: Sat, 20 Feb 2010 15:27:37 +0200
Message-ID: <201002201527.37643.opurdila@ixiacom.com>
References: <1266532210-11536-1-git-send-email-opurdila@ixiacom.com> <1266532210-11536-3-git-send-email-opurdila@ixiacom.com> <4B7F9B65.1060309@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7F9B65.1060309@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 20 February 2010 10:20:53 you wrote:

> > +unsigned long *sysctl_local_reserved_ports;
> > +EXPORT_SYMBOL(sysctl_local_reserved_ports);
> > +
> 
> Sorry, this looks somewhat weird, why not just export
> inet_is_reserved_local_port()?
> 

My understanding is that if we do that than we won't be able to inline 
inet_is_reserved_local_port().  And as David said previously that will have a 
significant impact on performance.
