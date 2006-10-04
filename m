From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 0/2] [PATCH 0/2] Updated NetLabel/secid-reconciliation
  bits and a bugfix
Date: Wed, 04 Oct 2006 15:42:08 -0400
Message-ID: <45240E90.4050405@hp.com>
References: <36282A1733C57546BE392885C0618592015CF940@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, eparis@redhat.com, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:64673 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1750934AbWJDTmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 15:42:10 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF940@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>>As for the rest of the network labeling, please work 
>>
>>together with Venkat 
>>
>>>and the SELinux developers on a final patchset which meets 
>>
>>all of the 
>>
>>>design goals and has been tested, with policy which has been merged 
>>>upstream and is available via Fedora devel.  Please keep 
>>
>>the discussion 
>>
>>>going, but ensure that the final patchset for review and merge 
>>>consideration is a complete set against the current git 
>>
>>kernel coming from 
>>
>>>one person.
>>
>>I'm trying :)  When I posted the NetLabel secid support patch 
>>last week
>>I asked Venkat if he could merge it with the main secid 
>>patchset (due to
>>size and dependencies that seemed like the most reasonable course of
>>action).  For reasons I'm not aware of he chose not to.
> 
> 
> FYI- I am no NetLabel expert, and the pathset I sent out that day included
> the peersid changes. And since you were going to have to post a patch for
> that
> again, I thought it best you ported and reposted the entire patch again.

I'm not talking about the peer_sid changes, although I'm glad they are
part of the secid patchset - thank you.  I'm talking about the patch I
keep reposting to include NetLabel is the secid reconciliation path.

There was a secid patchset posted on Thursday (9/28) night, I posted the
a patch on Friday (9/29) to provide NetLabel support.

There was a secid patchset posted on Sunday (10/1) night, I respun the
NetLabel support patch on Monday (10/2) - "v2".

I respun the NetLabel support patch to take into account Stephen
Smalley's comments on Monday (10/2) - "v3".

There was a small update to the secid patches yesterday (10/3) so I
respun the NetLabel support patch (10/4) - "v4".

>> As a result I
>>keep posting updated patches backed against Venkat's latest and
>>incorporating the latest feedback.
>  
> And let's keep this going like this on the selinux list. When all the
> testing is done and selinux ok's the patchsets, I will combine them
> and send them onto netdev. How does that sound?

Yes, the discussion is a good one I don't want to disrupt that.

I would prefer if all of the patches were in one patchset, pushed out by
one person as that would save me from having to respin my patch if all I
need to do is update it for the latest secid patches.  I think that has
value so people can review/test/etc all of the parts as one coherent
patchset.  However, it's ultimately up to you as you are the one working
on the main secid patchset.

>>Venkat, can you please merge the latest my latest NetLabel 
>>secid support
>>patch in with your next release?
>  
> I would, but it currently is premature. As James says, let's
> get policy done, the design proven, and tested and then we will
> go to netdev with one patchset.

I think it's easier to decide on policy, review the design, and test it
all if there is one place/patchset with all of the latest bits/patches.
 Right not it's not that easy with different patches scattered around.

-- 
paul moore
linux security @ hp
