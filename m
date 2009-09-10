From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: [Linux-ATM-General] [PATCH] atm/br2684: netif_stop_queue() when
 atm	device busy and netif_wake_queue() when we can send packets again.
Date: Thu, 10 Sep 2009 23:30:44 +0200
Message-ID: <4AA97004.2010904@hiramoto.org>
References: <4A9901E7.9040804@hiramoto.org> <1251545092-18081-1-git-send-email-karl@hiramoto.org> <4AA95838.4010007@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdccac.dreamhost.com ([208.97.132.202]:34980 "EHLO
	spunkymail-a13.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752643AbZIJVap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 17:30:45 -0400
In-Reply-To: <4AA95838.4010007@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip A. Prindeville wrote:
> I had noticed that with my Solos card, and using Qwest 7062/896kb/s
> service that I was typically only getting ~400kb/s upstream, so I
> thought that delayed transmitter restarts might be the culprit and
> decided to try out this patch.
>
> I'm running 2.6.27.26, and I modified the patch as below.
>
> Has anyone confirmed this patch (Karl's) against 2.6.27?
>
> Thanks,
>
> -Philip
I'd be interested in hearing comparisons with/without the patch.    What 
i have is no upstream packet loss with this patch, however slightly 
lower total throughput.  I think because the upper networking layers 
take time to restart the packet flow.   I'm not really sure if or how 
many packets to upper layers buffer.  I haven't had time to debug it 
further.

I don't have a solos card, but you may have to tweak the solos driver 
sk_sndbuf  value.

--
Karl
