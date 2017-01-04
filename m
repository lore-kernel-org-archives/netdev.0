From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Wed, 4 Jan 2017 13:51:13 +0200
Message-ID: <82df989f-09a7-a89a-a675-c45d190b049e@mellanox.com>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
 <20170102195522.7488179b@griffin>
 <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
 <20170104103301.GA30008@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0046.outbound.protection.outlook.com ([104.47.2.46]:53600
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758031AbdADLwB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 06:52:01 -0500
In-Reply-To: <20170104103301.GA30008@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/01/2017 12:33, Simon Horman wrote:
> On Tue, Jan 03, 2017 at 01:54:34PM +0200, Paul Blakey wrote:
>
> ...
>
> Hi Paul,
>
>> Matching name was from the idea that we are doing is matching.
>> And regarding documentation/flag names I didn't want tc tool to be need of a
>> update each time a new flag is introduced,
>> But I guess I can add two options like with ip_proto where you can specify
>> known flags by name but can also give a value.
>> What do you think about that?
>>
>> flags <FLAGS> / <HEX'/'HEX>
>> FLAGS => frag/no_frag/tcp_syn/no_tcp_syn ['|'<FLAGS>]*
>> e.g: flags frag|no_tcp_syn or flags 0x01/0x15
>> and the mask will have a on bits corresponds only to those flags specified.
> I suppose a flag is a flag and bitwise masking allows arbitrary matching
> on one or more flags. But I wonder if, as per your example above,
> it makes sense to mix IP (frag) and TCP flags in the same field of the
> classifier.
It mimics the kernel packing of flags, I have no problem either way 
(flags, or ip_flags/tcp_flags pairs), what do you think jiri?
