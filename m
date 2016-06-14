From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 08/12] net: dsa: mv88e6xxx: read switch ID from info
Date: Tue, 14 Jun 2016 17:01:38 -0400
Message-ID: <87k2hrbi31.fsf@ketchup.mtl.sfl>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com> <20160614183153.32327-9-vivien.didelot@savoirfairelinux.com> <fea82e7e-7c1d-baac-8a91-07cd94b13b6c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36706 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbcFNVBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:01:42 -0400
In-Reply-To: <fea82e7e-7c1d-baac-8a91-07cd94b13b6c@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

>> -	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
>> +	of_id = of_match_node(mv88e6xxx_of_id_table, np);
>
>     You could use of_device_get_match_data() here.
>
>> +	if (!of_id)
>> +		return -EINVAL;
>> +
>> +	info = (const struct mv88e6xxx_info *)of_id->data;
>
>     Pointer casts from 'void *' are automatic.

I applied your comments and also squashed patches 7 and 8 together.
I'll respin a v3 soon unless there are other comments.

Thanks,

        Vivien
