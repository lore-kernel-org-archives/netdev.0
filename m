From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IPVS: Move userspace definitions to include/linux/ip_vs.h
Date: Thu, 24 Jul 2008 13:34:27 +0200
Message-ID: <f4845fc0807240434p4fef9f77u8dc1d006e393bc7b@mail.gmail.com>
References: <1216894489-13060-1-git-send-email-juliusv@google.com>
	 <20080724111434.GA30382@verge.net.au> <488865FA.4040002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Simon Horman" <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, vbusam@google.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60479 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbYGXLeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 07:34:36 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id m6OBYSbi003873
	for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 12:34:29 +0100
Received: from wf-out-1314.google.com (wfd26.prod.google.com [10.142.4.26])
	by wpaz5.hot.corp.google.com with ESMTP id m6OBYRf0019288
	for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 04:34:28 -0700
Received: by wf-out-1314.google.com with SMTP id 26so2173401wfd.26
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 04:34:27 -0700 (PDT)
In-Reply-To: <488865FA.4040002@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 1:22 PM, Patrick McHardy <kaber@trash.net> wrote:
>>> +/* Move it to better place one day, for now keep it unique */
>>> +#define NFC_IPVS_PROPERTY      0x10000
>
> Does this have any connection to the skb flag? If so, does
> it really belong in the userspace interface?

This doesn't seem to be used at all anymore, but I didn't want to
remove it in the same patch... should I?

>>> +struct ip_vs_service_user {
>>> +       /* virtual service addresses */
>>> +       u_int16_t               protocol;
>>> +       __be32                  addr;           /* virtual ip address */
>>> +       __be16                  port;
>
> If you switch the above two you plug two holes in the struct.

Unfortunately, these structs all have to stay as they are because they
are used by old ipvsadms. That was the whole reason for implementing
the Netlink interface.

Julius

-- 
Google Switzerland GmbH
