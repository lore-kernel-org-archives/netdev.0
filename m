From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [Patch] (updated) netfilter: remove deprecated
 CONFIG_NF_CT_ACCT
Date: Thu, 15 Oct 2009 13:18:23 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0910151307260.27202@bizon.gios.gov.pl>
References: <20091015080211.4561.78538.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-1116381015-1255605504=:27202"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, netfilter-devel-owner@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:39217 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757819AbZJOL3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 07:29:40 -0400
In-Reply-To: <20091015080211.4561.78538.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1116381015-1255605504=:27202
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT


Adding CC to netfilter-devel-owner@vger.kernel.org, where netfilter 
related issues are discussed.

On Thu, 15 Oct 2009, Amerigo Wang wrote:

>
> CONFIG_NF_CT_ACCT is scheduled to be removed in 2.6.29.
>
> Cc: Krzysztof Piotr Oledzki <ole@ans.pl>
> Signed-off-by: WANG Cong <amwang@redhat.com>

This is not so easy - it was decided that we don't want to remove it just 
that because of connbytes. The final conclusion was to keep it disabled by 
default (if not enabled by kernel/modules/sysctl option) but enabling it 
automatically for the current NS if nefilter rules contains "-m 
connbytes".

Sorry, I should have gotten into this and finished it earlier, my bad. :(

Best regards,

 				Krzysztof Olêdzki
---1144830174-1116381015-1255605504=:27202--
