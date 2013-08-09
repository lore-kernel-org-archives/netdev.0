From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 09:11:22 +0200
Message-ID: <5204961A.5020707@bfs.de>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>	 <20130808210918.GE5502@mwanda>	 <20130808.142054.1541424422807503741.davem@davemloft.net>	 <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com> <1376015984.2087.31.camel@joe-AO722>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kumar Gaurav <kumargauravgupta3@gmail.com>,
	David Miller <davem@davemloft.net>, dan.carpenter@oracle.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1376015984.2087.31.camel@joe-AO722>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 09.08.2013 04:39, schrieb Joe Perches:
> On Fri, 2013-08-09 at 07:54 +0530, Kumar Gaurav wrote:
>> On Friday 09 August 2013 03:03 AM, Joe Perches wrote:
>>> On Thu, 2013-08-08 at 14:20 -0700, David Miller wrote:
>>>> So what's the problem again? :-)
>> I'm quite new to kernel development. I saw in one of the patches which 
>> fixes IRQF_DISABLED issue by removing so i did.
> 
> Hi Kumar.
> 
> No worries, welcome.
> 
>>> Wouldn't it be better to do a sed 's/IRQF_DISABLED/0/' instead?
>>> Maybe Kumar wants to/is doing that?
>> Yes i wanted to do the same and i retrieved list of all programs 
>> containing IRQF_DISABLED but i didn't wanted to send all of them in one 
>> patch. I would be sending them for one program in one patch.
> 
> You should definitely not send a single patch.
> 
> $ git grep -w --name-only IRQF_DISABLED | wc -l
> 245
> 
> I think that's way too many modified files for a
> single patch.
> 
> If you do it, please remember to change bits like
> "(IRQF_<foo> | IRQF_DISABLED)" so that instead of
> "(IRQF_<foo> | 0)", you use just "IRQF_<foo>".
> 
> And, maybe it'd be better to use IRQF_TRIGGER_NONE
> instead of 0.
> 


yes !

re,
 wh


