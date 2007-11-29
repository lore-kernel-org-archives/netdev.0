From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH -mm] [RFC] I/OAT: Handle incoming udp through ioatdma
Date: Thu, 29 Nov 2007 18:43:35 -0500
Message-ID: <1196379815.4450.2.camel@localhost>
References: <BAE9DCEF64577A439B3A37F36F9B691C03853146@orsmsx418.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:47120 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763513AbXK2Xnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 18:43:39 -0500
Received: by py-out-1112.google.com with SMTP id u77so3959428pyb
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 15:43:39 -0800 (PST)
In-Reply-To: <BAE9DCEF64577A439B3A37F36F9B691C03853146@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-29-11 at 12:08 -0800, Nelson, Shannon wrote:
> [RFC] I/OAT: Handle incoming udp through ioatdma
> 
> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> If the incoming udp packet is larger than sysctl_udp_dma_copybreak, try
> pushing it through the ioatdma asynchronous memcpy.  This is very much
> the
> same as the tcp copy offload.  This is an RFC because we know there are
> stability problems under high traffic.


What stability problems?

Is there some magic sysctl_udp_dma_copybreak threshold value where you
start seeing the benefit of IOAT-ing? Since you mentioned
"students"<evil grin here>, it would be interesting to see data where
udp starts benefitting.


cheers,
jamal

