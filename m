From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH iproute] iptuntap: show processes using tuntap interface
Date: Thu, 1 Sep 2016 18:07:33 +0200
Message-ID: <a0542168-4437-ba01-d7ae-86bd5b0e5af6@stressinduktion.org>
References: <1472062105-17995-1-git-send-email-hannes@stressinduktion.org>
 <20160901090621.13026e9c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41752 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933890AbcIAQHg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:07:36 -0400
In-Reply-To: <20160901090621.13026e9c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.09.2016 18:06, Stephen Hemminger wrote:
> On Wed, 24 Aug 2016 20:08:25 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
>> Show which processes are using which tun/tap devices, e.g.:
>>
>> $ ip -d tuntap
>> tun0: tun
>> 	Attached to processes: vpnc(9531)
>> vnet0: tap vnet_hdr
>> 	Attached to processes: qemu-system-x86(10442)
>> virbr0-nic: tap UNKNOWN_FLAGS:800
>> 	Attached to processes:
>>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Applied, but needed a followon change to fix some style issues.

Thanks, the clean up looks good!
