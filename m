From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] iproute2: add dynamic index and name hashes
Date: Fri, 10 Dec 2010 19:35:48 +0200
Message-ID: <201012101935.49001.opurdila@ixiacom.com>
References: <1291993164-8793-1-git-send-email-opurdila@ixiacom.com> <20101210082040.230a2832@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:25552 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752499Ab0LJRfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:35:50 -0500
In-Reply-To: <20101210082040.230a2832@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  };
> > 
> > -static struct idxmap *idxmap[16];
> 
> This is user space, and memory space is realtively cheap. Why not just
> make initial idxmap much bigger and be done with it.

Well, we can use up to 128K interfaces and hard coding it for that number 
seems obscene to me :) But I guess a default like 16K is OK.

The patch also adds a name hash, is that part OK?

Thanks,
tavi
