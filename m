From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 0/2] [PATCH 0/2] Updated NetLabel/secid-reconciliation
 bits and a bugfix
Date: Wed, 04 Oct 2006 14:54:33 -0400
Message-ID: <45240369.4030107@hp.com>
References: <20061004154629.186531000@hp.com> <Pine.LNX.4.64.0610041439050.6196@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	sds@tycho.nsa.gov, vyekkirala@TrustedCS.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:43175 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1422930AbWJDSyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 14:54:46 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0610041439050.6196@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Wed, 4 Oct 2006, paul.moore@hp.com wrote:
> 
>>This patchset includes an update to the NetLabel/secid-reconciliation patch,
>>replacing my "v3" patch from earlier this week, and a bugfix patch to cure a
>>race condition found during testing this week.  The bugfix patch does not
>>rely on the secid patches and should be merged regardless as it fixes a bug
>>which has been around since the very first NetLabel patches (not sure why I
>>didn't see this sooner).
> 
> So, patch 2/2 should go in on it's own against upstream?  If so, in 5B
> future, please post such patches separately.

Yes, please commit patch 2/2 regardless as it fixes a bug which is not
dependent on any of the secid patches which are being discussed.  My
apologies for including it in the same patchset, I'll be sure to split
it up next time.

> As for the rest of the network labeling, please work together with Venkat 
> and the SELinux developers on a final patchset which meets all of the 
> design goals and has been tested, with policy which has been merged 
> upstream and is available via Fedora devel.  Please keep the discussion 
> going, but ensure that the final patchset for review and merge 
> consideration is a complete set against the current git kernel coming from 
> one person.

I'm trying :)  When I posted the NetLabel secid support patch last week
I asked Venkat if he could merge it with the main secid patchset (due to
size and dependencies that seemed like the most reasonable course of
action).  For reasons I'm not aware of he chose not to.  As a result I
keep posting updated patches backed against Venkat's latest and
incorporating the latest feedback.

Venkat, can you please merge the latest my latest NetLabel secid support
patch in with your next release?  If not, would you have a problem if I
pushed out a patchset which included your latest patches with the
NetLabel secid support patch and we used this patchset as the basis for
future work?

-- 
paul moore
linux security @ hp
