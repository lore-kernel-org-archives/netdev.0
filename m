From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Sat, 08 Jun 2013 18:56:43 +0800
Message-ID: <1370689003.868.3.camel@cr0>
References: <1370485211-11498-1-git-send-email-amwang@redhat.com>
	 <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab3FHK5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 06:57:03 -0400
In-Reply-To: <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-06 at 16:16 -0400, David Stevens wrote:
> > From: Cong Wang <amwang@redhat.com>
> 
> > 
> > There are some places casting the return value to void, actually
> > they can respect the return value.
> 
>         This changes the user-visible errno returns, adding new,
> undocumented errno returns for a POSIX-defined API.
> 

Good point! I will convert the such return value to documented ones, for
example, EINVAL.

Thanks!
