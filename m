From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: DPRINTKs in e1000 code (2.6.x kernels)
Date: Thu, 01 Jun 2006 15:22:26 -0700
Message-ID: <447F68A2.20605@intel.com>
References: <447D5B51.7030100@in.ibm.com>	 <23630a870399173fdc21603d9300d905@localhost> <1149199027.7160.22.camel@amitarora.in.ibm.com> <447F654A.3040406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amit Arora <aarora@in.ibm.com>, Auke Kok <sofar@foo-projects.org>,
	netdev@vger.kernel.org, amitarora@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:36782 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750800AbWFAWWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 18:22:45 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <447F654A.3040406@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Amit Arora wrote:
>> On Wed, 2006-05-31 at 16:30, Auke Kok wrote:
>>> On Wed, 31 May 2006 14:31:05 +0530, Amit K Arora <aarora@in.ibm.com> 
>>> wrote:
>>>> Should these DPRINTKs be removed from the 2.6.x e1000 code as well ?
>>> they already are. the patch was merged in 7.0.38-k2 or so which is 
>>> over a month ago. 
>>
>> I do not think these DPRINTKs have been removed from the latest code.
>> Or, they did get removed at some point of time, but somehow again got
>> added.
>> I checked in 2.16.17-rc4 kernel, and also in the following versions of
>> e1000 codebase (pulled from
>> git://lost.foo-projects.org/~ahkok/git/netdev-2.6):
>> e1000-7.0.38-k1, -k2 ... -k5  e1000-7.0.41
>>
>> All of the above versions have the concerned DPRINTKs in e1000_suspend()
>> and other routines.
>>
>> Please check once and let me know if I am missing something. Thanks!
> 
> git-show d0e027db7861ef03de0ac08494a9a61984d8f8b0
> 
> it's really in there - please use jgarzik's netdev#upstream branch. Not 
> sure if it already made it to 2.16.17-rc5, but I don't think this made 
> it into 2.16.17-rc4, so that is where you may be missing it.


I'm in need of coffee - these changes got queued for 2.6.18. They're in 
jgarziks netdev-2.6.git, but not anywhere in 2.6.17rcX

Auke
