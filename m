From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: Re: [PATCH 13/13] net: dsa: lan9303: lan9303_port_mdb_del remove port
 0
Date: Tue, 25 Jul 2017 09:57:14 +0200
Message-ID: <a267bd6d-a9c8-2ce0-ea1c-393f6e9e2df1@zenitel.com>
References: <3bf6b19359cc40939b2e075635ed55d2@nooslMX1.zenitelcss.com>
 <42090826-7498-4d90-f265-a7cf65a9e236@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <corbet@lwn.net>,
        <andrew@lunn.ch>, <vivien.didelot@savoirfairelinux.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta5.messagelabs.com ([195.245.231.140]:51758 "EHLO
        mail1.bemta5.messagelabs.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750872AbdGYH5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 03:57:21 -0400
In-Reply-To: <42090826-7498-4d90-f265-a7cf65a9e236@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24. juli 2017 18:57, Florian Fainelli wrote:
> On 07/20/2017 06:57 AM, Egil Hjelmeland wrote:
>> Workaround for dsa_switch_mdb_add adding CPU port to group,
>> but forgetting to remove it:
>>
> Should not we move this logic one layer above into DSA then such that
> insertions and removals are strictly symmetrical in which and how many
> ports are targeted?
> 

Agree. I included the patch more as a bug report. I will remove it in
patch v2. I don't really feel competent to fix the issue in DSA. It is
probably better if you DSA people look at it. I do suspect DSA need
to do more bookkeeping?

Egil

DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
