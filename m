From: Amit Arora <aarora@in.ibm.com>
Subject: Re: DPRINTKs in e1000 code (2.6.x kernels)
Date: Thu, 01 Jun 2006 14:57:07 -0700
Message-ID: <1149199027.7160.22.camel@amitarora.in.ibm.com>
References: <447D5B51.7030100@in.ibm.com>
	 <23630a870399173fdc21603d9300d905@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	amitarora@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49584 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750735AbWFAV6R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 17:58:17 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k51LwFAH002240
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 17:58:16 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k51LwD7t155170
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 15:58:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k51LwDvD026270
	for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 15:58:13 -0600
To: Auke Kok <sofar@foo-projects.org>
In-Reply-To: <23630a870399173fdc21603d9300d905@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-31 at 16:30, Auke Kok wrote:
> On Wed, 31 May 2006 14:31:05 +0530, Amit K Arora <aarora@in.ibm.com> wrote:
> > 
> > Should these DPRINTKs be removed from the 2.6.x e1000 code as well ?
> 
> they already are. the patch was merged in 7.0.38-k2 or so which is over a month ago. 

I do not think these DPRINTKs have been removed from the latest code.
Or, they did get removed at some point of time, but somehow again got
added.
I checked in 2.16.17-rc4 kernel, and also in the following versions of
e1000 codebase (pulled from
git://lost.foo-projects.org/~ahkok/git/netdev-2.6):
e1000-7.0.38-k1, -k2 ... -k5  
e1000-7.0.41

All of the above versions have the concerned DPRINTKs in e1000_suspend()
and other routines.

Please check once and let me know if I am missing something. Thanks!

> Also, if you are getting these errors there are several fixes in 7.0.38+ in the kernel that might be related. especially the WoL fix that re-enables the shutdown handler correctly might fix this issue for you. Please give this kernel/module a try (see http://www.mail-archive.com/netdev@vger.kernel.org/msg12689.html).
> 
> Cheers,
> 
> Auke


Regards,
Amit Arora

