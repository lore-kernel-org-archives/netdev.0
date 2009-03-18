From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 16:52:27 +0200
Message-ID: <200903181652.27928.denys@visp.net.lb>
References: <20090318112937.675BF13A4B0@koiott.tartu-labor> <Pine.LNX.4.64.0903181332140.13734@ondatra.tartu-labor> <49C107AB.1030003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50190 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbZCROwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 10:52:19 -0400
In-Reply-To: <49C107AB.1030003@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 March 2009 16:39:39 Patrick McHardy wrote:
>
> On top it has far smaller code and less memory usage as soon as
> you have more than one CPU, its lockless, no default counters,
> no overhead for unused chains, etc etc.
>
> When the time has come, I will of course post benchmarks.
>
Thanks a lot for your code Patrick.
I will try as soon as i can.

I dont think hash and rbtrees is suboptimal.
I have really a lot of situations where i need large set of ip's or ports to 
be added in similar rule, which is forced to be linear. And if i even build 
tree manually - it will be really headache to add new hosts.

nftables looks very promissing in this case
