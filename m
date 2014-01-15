From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2] openvswitch: Pad OVS_PACKET_ATTR_PACKET if
 linear copy was performed
Date: Wed, 15 Jan 2014 14:53:48 -0800
Message-ID: <CAEP_g=_o1n5QO1P-yAo6wwJ45SOAyVtkQP2X_G0jq2ezpn34Aw@mail.gmail.com>
References: <20140114161640.GA24121@casper.infradead.org> <20140114161911.GB24121@casper.infradead.org>
 <20140114162749.GC24121@casper.infradead.org> <20140114.190354.1862604735799307127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Zoltan Kiss <zoltan.kiss@citrix.com>,
	Thomas Graf <tgraf@redhat.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:38003 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751434AbaAOWyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 17:54:09 -0500
Received: by mail-ie0-f171.google.com with SMTP id to1so2983049ieb.2
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 14:54:08 -0800 (PST)
In-Reply-To: <20140114.190354.1862604735799307127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 7:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Tue, 14 Jan 2014 16:27:49 +0000
>
>> While the zerocopy method is correctly omitted if user space
>> does not support unaligned Netlink messages. The attribute is
>> still not padded correctly as skb_zerocopy() will not ensure
>> padding and the attribute size is no longer pre calculated
>> though nla_reserve() which ensured padding previously.
>>
>> This patch applies appropriate padding if a linear data copy
>> was performed in skb_zerocopy().
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>> ---
>> v2: initialize padding to 0's
>
> Jesse do you want to queue this up or should I apply it directly?

I queued it up, thanks.
