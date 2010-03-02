From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Tue, 2 Mar 2010 12:38:01 +0100
Message-ID: <20100302113800.GB2362@dhcp-lab-161.englab.brq.redhat.com>
References: <1267351922.10409.2.camel@lb-tlvb-vladz> <20100301133339.GB2440@dhcp-lab-161.englab.brq.redhat.com> <1267466347.19491.31.camel@nseg_linux_HP1.broadcom.com> <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2B3FE@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Matthew Carlson <mcarlson@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534Ab0CBLjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 06:39:54 -0500
Content-Disposition: inline
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2B3FE@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 02:38:39AM -0800, Vladislav Zolotarov wrote:
> After reading a Pentium Developers Manual I'm afraid I might have assumed wrong and there is needed a read memory barrier to ensure that the bit testing is performed not earlier the specified location in the code flow (due to CPU reordering).

Linux supports more relaxed cpu's than Pentium :)

> Dave, as an author of atomic_ops.txt paper I think u r the best man to ask. Could u pls. clarify that if we need to ensure that the bit testing is needed AFTER the consumer update (namely after the smp_wmb()) I need to replace it with the smp_mb().
> 
> If yes, it's a clear bug and I'll prepare an appropriate patch immediately.

Yes, it's a bug.

Thanks
Stanislaw
