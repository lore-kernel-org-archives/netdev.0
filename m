From: Rick Jones <rick.jones2@hp.com>
Subject: Re: wither bounds checking for networking sysctls
Date: Fri, 31 Aug 2007 10:14:53 -0700
Message-ID: <46D84C8D.4070009@hp.com>
References: <46D76A3D.9090207@hp.com> <20070830205939.2f85a567@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:56320 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965417AbXHaRPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 13:15:32 -0400
In-Reply-To: <20070830205939.2f85a567@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 30 Aug 2007 18:09:17 -0700
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
>>While messing about with "sysctl_tcp_rto_min" I went back and forth a 
>>bit as to whether there should have been bounds checking (as did some of 
>>the folks who did some internal review for me).  That leads to the 
>>question - is it considered worthwhile to add a bit more bounds checking 
>>to sundry networking sysctls?
>>
>>rick jones
> 
> 
> IMHO As long as the any value from sysctl doesn't crash kernel, we
> should let it go. Enforcing RFC policy or inter-dependencies seems
> likes a useless exercise.

I was thinking more along the lines of more fundamental things - like 
precluding negative values when something is clearly a positive.

rick jones
