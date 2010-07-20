From: Roy Marples <roy@marples.name>
Subject: Re: recv(2), MSG_TRUNK and kernels older than 2.6.22
Date: Tue, 20 Jul 2010 10:08:26 +0100
Message-ID: <4C45678A.4080408@marples.name>
References: <4C455DC3.1050304@marples.name> <1279616099.2498.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uberserver.marples.name ([77.75.106.61]:65433 "EHLO
	uberserver.marples.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758362Ab0GTJI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 05:08:28 -0400
In-Reply-To: <1279616099.2498.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/07/2010 09:54, Eric Dumazet wrote:
> Is it for the dhcpcd problem we talk about few week ago, disturbed by
> new 64bit stats ?

Yes

>
> Why do you want to have a fixed size of 256 bytes ?
>
> Using 8192 bytes on stack would avoid MSG_TRUNK mess.

Yes it would, but that doesn't answer my question :)
I would like to use a buffer big enough, but not a whole 8k in size.
dhcpcd has quite a small runtime and I'd like to keep it that way.

Thanks

Roy
