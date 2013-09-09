From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] bnx2x: avoid atomic allocations during initialization
Date: Mon, 09 Sep 2013 14:20:03 +0200
Message-ID: <522DBCF3.50709@redhat.com>
References: <1378411989-19775-1-git-send-email-mschmidt@redhat.com> <20130906.142735.458916282873797040.davem@davemloft.net> <504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751960Ab3IIMUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 08:20:13 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2013 03:45 AM, Dmitry Kravkov wrote:
> Once you allocated the memory during initialization , you will most
> probably fail to allocate its replacement during RX handling (on this
> machine).

Why do you think this would happen "most probably"? I would instead
expect the VM subsystem to respond to the memory pressure created by the
initial GFP_KERNEL allocations by freeing some memory to allow the
future atomic allocations to succeed.

Michal
