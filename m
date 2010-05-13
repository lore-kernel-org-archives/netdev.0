From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: RE: does the broadcom bnx2x support RSS/multi queue
Date: Thu, 13 May 2010 14:32:20 +0300
Message-ID: <1273750340.1423.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
 <1273650119.2621.5.camel@edumazet-laptop>
 <1273655947.4491.5.camel@lb-tlvb-eilong.il.broadcom.com>
 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497DECAE8@MILEXCH2.ds.jdsu.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jon Zhou" <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2306 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758696Ab0EMLci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 07:32:38 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497DECAE8@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-05-13 at 02:44 -0700, Jon Zhou wrote:
> insmod ./PF_RING/drivers/broadcom/netxtreme2-5.2.50/bnx2x-1.52.12/src/bnx2x.ko multi_mode=1 num_queues=4 int_mode=3 debug=1
There is no need to set multi_mode or int_mode - you are using the
default values. However, I need more information on why you are using
INTA and not MSI-X, so please set the debug to 0x20

> but seems MSI not enabled:
> 34:         26          0          0          0          0          0          0          0          0          0          0          0   49470611   63427140          0          0   IO-APIC-fasteoi   eth5
Indeed, you are using INT# - this is why you do not have multi-queue.

Eilon


