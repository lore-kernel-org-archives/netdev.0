From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] cxgb3 - Parity initialization for T3C adapters
Date: Fri, 07 Dec 2007 18:26:39 -0500
Message-ID: <4759D6AF.5050205@garzik.org>
References: <20071205181527.22106.73134.stgit@speedy5> <4759A6EA.1050106@garzik.org> <4759CD92.2070604@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54847 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974AbXLGX0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 18:26:42 -0500
In-Reply-To: <4759CD92.2070604@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> Jeff Garzik wrote:
>> Divy Le Ray wrote:
>>> From: Divy Le Ray <divy@chelsio.com>
>>>
>>> Add parity initialization for T3C adapters.
>>>
>>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>> ---
>>>
>>>  drivers/net/cxgb3/adapter.h       |    1 
>>>  drivers/net/cxgb3/cxgb3_main.c    |   82 ++++++++++++
>>>  drivers/net/cxgb3/cxgb3_offload.c |   15 ++
>>>  drivers/net/cxgb3/regs.h          |  248 
>>> +++++++++++++++++++++++++++++++++++++
>>>  drivers/net/cxgb3/sge.c           |   24 +++-
>>>  drivers/net/cxgb3/t3_hw.c         |  131 +++++++++++++++++---
>>>  6 files changed, 472 insertions(+), 29 deletions(-)
>>
>> dropped patches 2-3, did not apply
>>
>>
> 
> Hi Jeff,
> 
> I noticed that you applied the first one of this 3 patches series to the 
> #upstream-fixes branch.
> These patches are intended to the #upstream (2.6.25) branch, as they are 
> built on top of the
> last 10 patches committed - 9 from me, and the white space clean up 
> (thanks!).
> May be this is the reason why they did not apply.

Ah... you need to tell me these things.  I looked for a kernel version 
in your messages but did not see one.

Does the patch #1 need to be reverted for 2.6.24?


> On this topic, I have a question: how do I get to see all the netdev-2.6 
> branches ?
> After cloning a free  netdev-2.6 tree, 'git branch' shows only the 
> master branch:
> 
> bash-3.1$ git --version
> git version 1.5.3.rc4.29.g74276-dirty
> -bash-3.1$ stg clone 
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
> netdev-2.6-fresh
> Cloning 
> "git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git" 
> into "netdev-2.6-fresh"...
> Initialized empty Git repository in /opt/sources/netdev-2.6-fresh/.git/
> remote: Generating pack...
> remote: Counting objects: 620879
> Done counting 633562 objects.
> remote: Deltifying 633562 objects...
> remote:  100% (633562/633562) done
> Indexing 633562 objects...
> remote: Total 633562 (delta 517968), reused 594305 (delta 478716)
> 100% (633562/633562) done
> Resolving 517968 deltas...
> 100% (517968/517968) done
> Checking 23058 files out...
> 100% (23058/23058) done
> done
> -bash-3.1$ cd netdev-2.6-fresh/
> -bash-3.1$ git branch
> * master

git fetch -f $NETDEV_URL upstream:upstream

copies the latest upstream branch from netdev-2.6.git, and stores it as 
your local upstream branch.

You may do the same for #upstream-fixes too.

	Jeff



