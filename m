From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [Linux-ATM-General] [PATCH] atm/br2684: netif_stop_queue() when
 atm	device busy and netif_wake_queue() when we can send packets again.
Date: Fri, 11 Sep 2009 12:56:59 -0700
Message-ID: <4AAAAB8B.1050304@redfish-solutions.com>
References: <4A9901E7.9040804@hiramoto.org> <1251545092-18081-1-git-send-email-karl@hiramoto.org> <4AA95838.4010007@redfish-solutions.com> <4AA97004.2010904@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60566 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751923AbZIKT6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:58:20 -0400
In-Reply-To: <4AA97004.2010904@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karl Hiramoto wrote:
> Philip A. Prindeville wrote:
>> I had noticed that with my Solos card, and using Qwest 7062/896kb/s
>> service that I was typically only getting ~400kb/s upstream, so I
>> thought that delayed transmitter restarts might be the culprit and
>> decided to try out this patch.
>>
>> I'm running 2.6.27.26, and I modified the patch as below.
>>
>> Has anyone confirmed this patch (Karl's) against 2.6.27?
>>
>> Thanks,
>>
>> -Philip
> I'd be interested in hearing comparisons with/without the patch.    What
> i have is no upstream packet loss with this patch, however slightly
> lower total throughput.  I think because the upper networking layers
> take time to restart the packet flow.   I'm not really sure if or how
> many packets to upper layers buffer.  I haven't had time to debug it
> further.
> 
> I don't have a solos card, but you may have to tweak the solos driver
> sk_sndbuf  value.
> 
> -- 
> Karl

I'm running with the patch right now...  Can't tell if latency has been affected.

Seems to be working a bit better, but I've not done any formalized testing.

-Philip

