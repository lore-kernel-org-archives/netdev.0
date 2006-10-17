From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Tue, 17 Oct 2006 18:32:46 +0100 (IST)
Message-ID: <Pine.LNX.4.64.0610171832160.2318@skynet.skynet.ie>
References: <200610052250.55146.ak@suse.de> <1160101394.29690.48.camel@flooterbu>
 <20061006143312.GB9881@skynet.ie> <20061006153629.GA19756@in.ibm.com>
 <20061006171105.GC9881@skynet.ie> <1160157830.29690.66.camel@flooterbu>
 <20061006200436.GG19756@in.ibm.com> <Pine.LNX.4.64.0610091049390.30765@skynet.skynet.ie>
 <20061016181613.GA30090@in.ibm.com> <20061016165814.13b99e5e.akpm@osdl.org>
 <20061017121836.GI30596@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, vgoyal@in.ibm.com,
	Steve Fox <drfickle@us.ibm.com>, Andi Kleen <ak@suse.de>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Martin Bligh <mbligh@mbligh.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kmannth@us.ibm.com, Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751353AbWJQRcu@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061017121836.GI30596@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Oct 2006, Adrian Bunk wrote:

> On Mon, Oct 16, 2006 at 04:58:14PM -0700, Andrew Morton wrote:
>> On Mon, 16 Oct 2006 14:16:13 -0400
>> Vivek Goyal <vgoyal@in.ibm.com> wrote:
>>
>>>
>>> Can you please have a look at the attached patch
>>
>> Looks like a fine patch to me, although it could benefit from a comment
>> explaining why all those PAGE_ALIGN()s are in there.
>>
>>> and include it in -mm.
>>
>> Does it fix a patch in -mm or is it needed in mainline?
>
> The bug in my list was reported to be present in mainline [1].
>

Confirmed. This bug is present in 2.6.19-rc2

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
