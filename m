From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Thu, 17 Dec 2009 17:24:32 +0100
Message-ID: <200912171724.32711.schmto@hrz.tu-chemnitz.de>
References: <4B298118.2000608@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:60143 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbZLQQud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 11:50:33 -0500
In-Reply-To: <4B298118.2000608@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Philip,

interesting .. i am on the way to implement a DSCP/CS statistic to the kernel. 
We need this for network traffic accounting. The concept is the following: 

We create a virtual file /pro/net/ipdscp , this includes several DSCP/CS 
counters. See http://www.iana.org/assignments/dscp-registry/. Every time 
ip_rcv_finish() is called, we take a look at the DSCP/CS (iph->tos) value and 
increment the related counter. If you're interested in, i will send you a 
patch ? ..  

Maybe this is a good starting point for an DSCP/CS implementation. I was also 
shocked that the kernel do not really handle DiffServ thinks. 

> Assuming my crusade to get various common apps and services (wget, TB, FF,
>  Sendmail, Cyrus, ProFTPd, etc) to use DSCP/CS marking (very few apps
>  currently use DSCP or precedence marking), then kernels with the proper
>  default behavior will need to start shipping, right?  I.e. out-of-the-box
>  kernels should handle such apps without further configuration, such as
>  needing to have the DSCP iptables module installed.  They should "just
>  work".
Right. 

Best regards,
Torsten
