From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bk patches] net driver updates
Date: Tue, 26 Aug 2003 13:25:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4B9814.2090202@pobox.com>
References: <20030817183137.GA18521@gtf.org> <20030823154231.A11381@electric-eye.fr.zoreil.com> <20030826171754.GD16831@matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, torvalds@osdl.org,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike Fedyk <mfedyk@matchmail.com>
In-Reply-To: <20030826171754.GD16831@matchmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mike Fedyk wrote:
> On Sat, Aug 23, 2003 at 03:42:31PM +0200, Francois Romieu wrote:
> 
>>Jeff Garzik <jgarzik@pobox.com> :
>>[net-drivers-2.6 update]
>>
>>> drivers/net/sis190.c              | 2094 +++++++++++++++++++++++++++++---------
>>
>>
>>synchronize_irq() requires an argument when built with CONFIG_SMP.
> 
> 
> Shouldn't it also require it for the UP case?  Or is this one of those
> subtle things that tells you it's not working on SMP?


the latter :)

	Jeff
