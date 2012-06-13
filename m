From: "Merav Sicron" <meravs@broadcom.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues
 default 8 queues
Date: Wed, 13 Jun 2012 18:14:20 +0300
Message-ID: <1339600460.17240.69.camel@lb-tlvb-meravs.il.broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
 <1339591464-10554-9-git-send-email-meravs@broadcom.com>
 <1339581175.22704.342.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2542 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab2FMMMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:12:32 -0400
In-Reply-To: <1339581175.22704.342.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Wed, 2012-06-13 at 11:52 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> > This patch removed the limitation in the code for 16 RSS queues. The default
> > (without other instruction from the user) number of queues is determined
> > according to the number of MSI-X vectors supported for that function, the number
> > of CPUs in the system, and a maximum of 8 queues.
> 
> Thats a very confusing changelog
> 
> You meant : " a minimum of 8 queues" ?
> 
No, I meant maximum...for example in a system with 16 CPUs we will
allocate 8 RSS queues. We saw that in most scenarios we tested there was
no need for more than 8 queues to get the maximal throughput, and by
limiting to 8 by default we reduce the allocated memory. We do provide
ethtool -L support so that the user could request more RSS queues if
desired.

> You should give more explanations, because its a sensible area for
> performances.
> 
Thanks,
Merav
