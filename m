From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net-next 4/4] qlcnic: Use generic fdb handler when
 driver options are not enabled.
Date: Thu, 28 Feb 2013 23:35:39 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E2D62C7@avmb2.qlogic.org>
References: <1362093183-5938-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>
To: Vlad Yasevich <vyasevic@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.189] ([216.32.180.189]:6267 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751078Ab3B1XhQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 18:37:16 -0500
In-Reply-To: <1362093183-5938-5-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Content-ID: <CFE68869CDD0DE439527071FA02249DD@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2/28/13 3:13 PM, "Vlad Yasevich" <vyasevic@redhat.com> wrote:

>Allow qlcnic to use the generic fdb handler when the driver options
>are not enabled.   Untill the driver is fully fixed, this allows
>the use of the FDB interface with qlogic driver, but simply puts
>the driver into promisc mode since the driver currently does not
>support IFF_UNICAST_FLT.
>
>CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>CC: Sony Chacko <sony.chacko@qlogic.com>
>CC: linux-driver@qlogic.com
>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>---
>drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   21
>++++++---------------
>1 files changed, 6 insertions(+), 15 deletions(-)

Thanks! Soon will add support for IFF_UNICAST_FLT

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
