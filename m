From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 09:40:24 +0900
Message-ID: <CAKD1Yr0cygxkc2hf7SDLU8zLsyWiAGcmYWOhXOT=rwGmHfCQ_Q@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <39efdc37-88cc-34c4-ad64-2f13fd0bc4a2@cumulusnetworks.com>
 <CAKD1Yr03OGoOGtCB9JTCkpQhiPGh+wZRMB96YNSy4WzR2ckTow@mail.gmail.com> <c5a29670-59df-af6e-17b7-15e44e5589a1@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34311 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbcHIAkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 20:40:46 -0400
Received: by mail-io0-f175.google.com with SMTP id q83so374049056iod.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 17:40:46 -0700 (PDT)
In-Reply-To: <c5a29670-59df-af6e-17b7-15e44e5589a1@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 9, 2016 at 1:27 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Your description states:
> "ping_v6_sendmsg never sets flowi6_oif, so it is not possible to
> ping an IPv6 address on a different interface."
>
> That code snippet above contradicts that -- flowi6_oif is set in ping_v6_sendmsg.

Ah, yes, thanks. Will fix the commit message.
