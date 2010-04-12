From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] vhost: Make it more scalable by creating a vhost	thread
 per device.
Date: Mon, 12 Apr 2010 10:50:43 -0700
Message-ID: <4BC35D73.8080801@hp.com>
References: <1270229480.13897.8.camel@w-sridhar.beaverton.ibm.com>	<1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>	<1270771542.31186.397.camel@w-sridhar.beaverton.ibm.com>	<20100411154719.GA9681@redhat.com>	<1271093731.1467.25.camel@w-sridhar.beaverton.ibm.com> <20100412174259.GA18507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, Tom Lendacky <toml@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:11089 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab0DLRuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 13:50:46 -0400
In-Reply-To: <20100412174259.GA18507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>
>>>Consider using Ingo's perf tool to get error bars, but looks good
>>>overall. 
>>
>>What do you mean by getting error bars?
> 
> 
> How noisy are the numbers?
> I'd like to see something along the lines of 85% +- 2%

In netperf terms that would be adding the confidence intervals calculations to 
the results - which will be done by that "runemomniagg2.sh" script I mentioned. 
When running multiple instance tests, it is very important to set the min and 
max iterations to the same value so no instance thinks to finish early.  The 
script does that, just want to make sure that those leveraging it do the same.

happy benchmarking,

rick jones
