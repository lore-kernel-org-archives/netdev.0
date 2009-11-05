From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 2.6.33/1 00/12] WiMAX patches for 2.6.33 (batch #1)
Date: Thu, 05 Nov 2009 10:17:31 -0800
Message-ID: <1257445051.3263.12.camel@localhost.localdomain>
References: <cover.1257370735.git.inaky@linux.intel.com>
	 <20091104.222450.149379897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11810 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757677AbZKESTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 13:19:31 -0500
In-Reply-To: <20091104.222450.149379897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-04 at 22:24 -0800, David Miller wrote:
> From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Date: Wed,  4 Nov 2009 13:39:36 -0800
> 
> > Please pull from:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git
> 
> Well you screwed up the patch posting and you screwed up the
> GIT tree too :-/
> 
> This git tree is not based upon a clone of net-next-2.6, instead
> it's a mish-mash of net-next-2.6 and some by-hand net-2.6
> pulls you've done yourself.

Yes I did -- I didn't give you the linux-2.6.33.y branch; my apologies.
The master branch is my testing tree and yes, that is not for merging.

So this pull should be against:

REPO   git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git
BRANCH linux-2.6.33.y

which is purely based off net-next-2.6 

$ git merge-base net-next-2.6/master linux-2.6.33.y
eb2ff967a587a4a784fd2390f38e324a5bec01ec

$ git log -1 eb2ff967a587a4a784fd2390f38e324a5bec01ec
eb2ff967a587a4a784fd2390f38e324a5bec01ec xfrm: remove skb_icv_walk

> Do NOT do this.
> 
> I even saw a random kbuild: change in there as well, which
> also shouldn't have been there.
> 
> Fix up your tree and make it pull cleanly before submitting this
> work again.
> 
> Also, when you give ma GIT URL you have to give me the branch to pull
> from at the end of the URL, if I just give that URL without the branch
> specifier to GIT for the pull it's going to fail.

This was my mistake too -- request-pull fails to detect the branch
properly when it is not given an end argument that matches HEAD and I
failed to realize that I was generating cover letter messages without
the branch.

This happened because I was breaking up the whole list of commits in
smaller chunks. Another item for the checklist.

It's maddening that I always manage to screw up somewhere :( My
apologies again.


