From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Thu, 17 Dec 2009 11:45:32 -0800
Message-ID: <4B2A8A5C.9070702@redfish-solutions.com>
References: <4B298118.2000608@redfish-solutions.com> <200912171724.32711.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54620 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965492AbZLQTpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 14:45:39 -0500
In-Reply-To: <200912171724.32711.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2009 08:24 AM, Torsten Schmidt wrote:
> Hi Philip,
> 
> interesting .. i am on the way to implement a DSCP/CS statistic to the kernel. 
> We need this for network traffic accounting. The concept is the following: 
> 
> We create a virtual file /pro/net/ipdscp , this includes several DSCP/CS 
> counters. See http://www.iana.org/assignments/dscp-registry/. Every time 
> ip_rcv_finish() is called, we take a look at the DSCP/CS (iph->tos) value and 
> increment the related counter. If you're interested in, i will send you a 
> patch ? ..  

That would be great.

> Maybe this is a good starting point for an DSCP/CS implementation. I was also 
> shocked that the kernel do not really handle DiffServ thinks. 

I think it would also be useful to rework the existing definition of rt_tos2priority() to have a DSCP/CS version that people could then select and build in their kernel via a simple CONFIG_DIFFSERV_COMPLIANT flag.

It could be selectable and default to off until a set cut-over point in the future, then it could become the default.

RFC-2474 is now 11 years old...  Odd that we're still not compliant.

-Philip


>> Assuming my crusade to get various common apps and services (wget, TB, FF,
>>  Sendmail, Cyrus, ProFTPd, etc) to use DSCP/CS marking (very few apps
>>  currently use DSCP or precedence marking), then kernels with the proper
>>  default behavior will need to start shipping, right?  I.e. out-of-the-box
>>  kernels should handle such apps without further configuration, such as
>>  needing to have the DSCP iptables module installed.  They should "just
>>  work".
> Right. 
> 
> Best regards,
> Torsten

