From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.25][NETNS]: Fix race between put_net() and netlink_kernel_create().
Date: Thu, 31 Jan 2008 14:05:57 +0300
Message-ID: <47A1AB95.4080202@openvz.org>
References: <47988F61.9070505@openvz.org> <20080130.193128.136832319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34727 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753639AbYAaLFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 06:05:53 -0500
In-Reply-To: <20080130.193128.136832319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Thu, 24 Jan 2008 16:15:13 +0300
> 
>> The comment about "race free view of the set of network 
>> namespaces" was a bit hasty. Look (there even can be only 
>> one CPU, as discovered by Alexey Dobriyan and Denis Lunev):
>  ...
>> Instead, I propose to crate the socket inside an init_net
>> namespace and then re-attach it to the desired one right
>> after the socket is created.
>>
>> After doing this, we also have to be careful on error paths
>> not to drop the reference on the namespace, we didn't get
>> the one on.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> Acked-by: Denis Lunev <den@openvz.org>
> 
> Applied, thanks.
> 

Thanks, David.

I have one more patch pending in netdev@ and some more to be sent
(cleanups, small fixes and net namespaces). Do I have to wait till
net-2.6.26, or can I start (re-)sending them while 2.6.25 merge
window is open?

Thanks,
Pavel
