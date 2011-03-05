From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 7/8] net: introduce rx_handler results and
 logic around that
Date: Sat, 5 Mar 2011 15:54:09 +0100
Message-ID: <20110305145408.GD8573@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-8-git-send-email-jpirko@redhat.com>
 <1299329330.4277.97.camel@localhost>
 <4D724E23.7020904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab1CEOyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 09:54:21 -0500
Content-Disposition: inline
In-Reply-To: <4D724E23.7020904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 05, 2011 at 03:52:19PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 05/03/2011 13:48, Ben Hutchings a =E9crit :
>>On Sat, 2011-03-05 at 11:29 +0100, Jiri Pirko wrote:
>>>This patch allows rx_handlers to better signalize what to do next to
>>>it's caller. That makes skb->deliver_no_wcard no longer needed.
>>[...]
>>>--- a/include/linux/netdevice.h
>>>+++ b/include/linux/netdevice.h
>>>@@ -390,7 +390,14 @@ enum gro_result {
>>>  };
>>>  typedef enum gro_result gro_result_t;
>>>
>>>-typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
>>>+enum rx_handler_result {
>>>+	RX_HANDLER_CONSUMED,
>>>+	RX_HANDLER_ANOTHER,
>>>+	RX_HANDLER_EXACT,
>>>+	RX_HANDLER_PASS,
>>>+};
>>[...]
>>
>>This should have a comment (preferably kernel-doc) clearly specifying
>>the meaning of each code, as the differences between ANOTHER/EXACT/PA=
SS
>>are fairly subtle.
>>
>>Ben,
>
>Except from the lack of proper documentation, this patch looks very go=
od.

Okay guys, I'll write something about that and send it in another patch=
=2E

>
>	Nicolas.
