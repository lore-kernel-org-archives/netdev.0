From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: Network Namespace status
Date: Fri, 14 Sep 2007 08:03:56 +0200
Message-ID: <46EA244C.1050702@hartkopp.net>
References: <m18x7a5qif.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Urs Thuermann <urs@isnogud.escape.de>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:22099 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbXINGFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 02:05:25 -0400
In-Reply-To: <m18x7a5qif.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Looking into my patch queue I have:
> 5 patches for cleaning up and making a per network namespace loopback device.
> 4 patches for making rtnetlink message processing per network namespace
> 1 patch for making AF_UNIX per network namespace
> 1 patch for making AF_PACKET per network namespace
>
> The ipv4 part of my patchset is currently working but it needs some
> more cleanup and reordering of patches before it is ready to go anywhere.
> Nothing has been done for ipv6, but the changes should very much parallel
> ipv4.
>
> The other protocols I haven't even looked at yet.
>   

Hi Eric,

can you send me your current AF_PACKET patch? I just want to update our
recent post of the CAN (controller area network) subsystem (AF_CAN)
which is (in some parts) similar to AF_PACKET. So i can take a look on
it to provide the latest technique in the next post ...

Thanks,
Oliver


