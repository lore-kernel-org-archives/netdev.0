From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Netxen packet loss with VLANs and LRO (was: [PATCH] netxen: fix
 LRO disable warning)
Date: Tue, 5 Apr 2011 12:38:08 +0200
Message-ID: <BANLkTi=i7A+J2WKPgATpH6ekFAeb-sn+UQ@mail.gmail.com>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
 <20110403190555.GA16196@torres.zugschlus.de> <99737F4847ED0A48AECC9F4A1974A4B80FD10E8E3C@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Haber <mh+netdev@zugschlus.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54231 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab1DEKi3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 06:38:29 -0400
Received: by qwk3 with SMTP id 3so124182qwk.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 03:38:28 -0700 (PDT)
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8E3C@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/5 Amit Salecha <amit.salecha@qlogic.com>:
>> On Mon, Mar 21, 2011 at 03:37:08AM -0700, Amit Kumar Salecha wrote:
>> > netxen_nic_set_flags() rejects data if other flag than ETH_FLAG_LR=
O
>> is set.
>> > Driver also supports NETIF_F_HW_VLAN_TX.
>> > Now compare data with ethtool_op_get_flags(), to get all supported
>> features.
[...]
>> My ethtool doesn't allow me to influence the LRO setting alone - it =
is
>> disabled when I set rx off but doesn't come on again when rx is set =
to
>> on again. So, ethtool -K rx off, ethtool -K rx on fixes the issue.
> If rx csum is disabled, LRO will be disable. LRO won't be enabled aut=
omatically if you enable rx csum.
> You need to explicitly enable LRO.

This will change once the driver is converted to hw_features.

Best Regards,
Micha=C5=82 Miros=C5=82aw
