From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: RE: does the broadcom bnx2x support RSS/multi queue
Date: Wed, 12 May 2010 12:58:21 +0300
Message-ID: <1273658301.5948.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
 <1273650119.2621.5.camel@edumazet-laptop>
 <1273655947.4491.5.camel@lb-tlvb-eilong.il.broadcom.com>
 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85DCD@MILEXCH2.ds.jdsu.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jon Zhou" <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1878 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab0ELJ6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 05:58:38 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85DCD@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-12 at 02:34 -0700, Jon Zhou wrote:
> hi eilon:
> 
> do you think I need to update the kernel also?

Kernel 2.6.27 supports Tx multi queue (Rx multi-queue was added even
before that), so theoretically you can update only the bnx2x. However,
you cannot use the bnx2x from the current kernel due to other changes
between 2.6.27 and the current kernel. So you need to download the bnx2x
from the Broadcom site.

Enjoy,
Eilon


