From: Patrick McHardy <kaber@trash.net>
Subject: Re: cannot set IP for ethernet
Date: Wed, 13 Jun 2007 13:25:45 +0200
Message-ID: <466FD439.2040807@trash.net>
References: <200706121441.13561.oliver@neukum.org> <200706131039.32011.oliver@neukum.org> <466FD17A.8040900@trash.net> <200706131321.30451.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758042AbXFML3O@vger.kernel.org>
In-Reply-To: <200706131321.30451.oliver@neukum.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Mittwoch, 13. Juni 2007 schrieb Patrick McHardy:
>>>>
>>>>This can happen if the initial inetdev allocation when the netdevice is
>>>>registered fails. I think it would make sense to try to allocate again
>>>>when adding addresses in that case, otherwise there is no way of
>>>>recovery other than unregistering and registering the device again.
>>>
>>>
>>>With your patch the problem has gone away. Is there a way to especially
>>>stress the system in that regard?
>>
>>
>>Its a failed allocation at NETDEV_REGISTER time. I guess you could
>>keep unloading + reloading the driver module to try to reproduce it.
> 
> 
> If that is the cause, why doesn't it strike from the very beginning? How
> come it fails after some time?


It might also be a failed in_ifaddr allocation. In that case my patch
shouldn't help though.
