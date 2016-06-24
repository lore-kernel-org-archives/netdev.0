From: Michal Soltys <soltys@ziu.info>
Subject: Re: switch / linux STP interoperation issues.
Date: Fri, 24 Jun 2016 23:54:47 +0200
Message-ID: <9da2c1a2-0e9d-9eb1-0c10-f790d0afc7ec@ziu.info>
References: <47b27017-6cfb-4a5c-8403-120848902173@ziu.info>
 <CAA1AmC2n1zW5gfZEyCdebQRL0QceovmK8tg5bBBor-ApB2bKYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jiri Pirko <jiri@mellanox.com>, Florian Westphal <fw@strlen.de>
To: Elad Raz <e@eladraz.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:49403 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbcFXVyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 17:54:54 -0400
In-Reply-To: <CAA1AmC2n1zW5gfZEyCdebQRL0QceovmK8tg5bBBor-ApB2bKYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-06-24 23:09, Elad Raz wrote:
> On Fri, Jun 24, 2016 at 10:14 PM, Michal Soltys <soltys@ziu.info> wrote:
>> Hi,
>>  <cut ..>
>> The switch respected BPDUs sent to it (if applicable) - for example it
>> complied properly if it's priority was less (numerically higher) than
>> linux's - showing linux box as root bridge, marking one port as root, the
>> other as alternate/blocking.
>>
>> The linux box itself was completely deaf to any BPDUs arriving to it (e.g.
>> if it's priority was lower) and just keept pushing its own data units all
>> the time with little care (quickly leading to loops in some scenarios).
>> Whether it was builtin stp implementation, or whether it was mstpd's
>> stp/rstp/mstp - the behaviour was the same.
>>
>>
>>
>> Linux is fresh stock archlinux (so vanilla 4.6.2 kernel and the most (or
>> almost) recent userland utils - iproute2, etc.), running on relatively
>> recent poweredge dell.
>>
>> I'm kind of lost at this point - am I missing some basic
>> options/sysctls/sysfs ? Is there some known incompatibility here somewhere
>> between switch/linux/nic/versions/etc. ? Some by-default enabled BPDU
>> filtering maybe ?
>>  <cut ..>
>>
>> Any suggestions / hints appreciated.
>
> Please see Ido Schimmel's fix "[net] bridge: Fix incorrect
> re-injection of STP packets",
> https://patchwork.ozlabs.org/patch/629768/
>

Thanks !

Will test it on monday asap.
