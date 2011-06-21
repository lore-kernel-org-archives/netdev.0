From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 20:32:14 -0300
Message-ID: <4E0129FE.7050709@redhat.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com> <4E011A96.7050509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, agospoda@redhat.com,
	nhorman@redhat.com, lwoodman@redhat.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab1FUXcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 19:32:20 -0400
In-Reply-To: <4E011A96.7050509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2011 07:26 PM, Prarit Bhargava wrote:
>> I'm thinking on a situation where we leave the systems with this enabled
>> and then an ordinary user starts pinging the network guessing the hexa to
>> cause reboots.
>>   
> 
> Good point Flavio, but that's *exactly* why I wrote this in single-shot
> mode.  I really think the code might be a bit too risky for most people
> to deploy in production environments.  It's too risky for me to let
> someone ping and ping and ping until they luckily hit the magic number
> and figure out how to bring *all* of my systems down.  What are the
> chances that a lab admin is smart enough to set the password to
> different numbers across different machines in a single lab?

I see your point.  I liked the patch because of the simplicity but
oh well, if we care that much about the security, then in the end
we will have something similar to what the xt_SYSRQ does already.

fbl

