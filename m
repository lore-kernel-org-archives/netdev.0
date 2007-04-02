From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [patch 10/10] forcedeth: work around NULL skb dereference crash
Date: Mon, 2 Apr 2007 10:34:47 -0700
Message-ID: <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com>
References: <20070402115325.GA945@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>
To: "Ingo Molnar" <mingo@elte.hu>, <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:16468 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbXDBRf5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 13:35:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070402115325.GA945@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had responded eariler to the thread asking you to try out the patch
found in bug 8058:
http://bugzilla.kernel.org/show_bug.cgi?id=8058

I believe that is the caush of the NULL skb dereference issue.

Thanks,
Ayaz


-----Original Message-----
From: Ingo Molnar [mailto:mingo@elte.hu] 
Sent: Monday, April 02, 2007 4:53 AM
To: akpm@linux-foundation.org
Cc: jeff@garzik.org; netdev@vger.kernel.org; Ayaz Abdulla
Subject: Re: [patch 10/10] forcedeth: work around NULL skb dereference
crash


* akpm@linux-foundation.org <akpm@linux-foundation.org> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> 
> work around a NULL skb dereference crash that occurs during high load.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

ping? No reaction from the forcedeth.c maintainer, yet.

	Ingo
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
