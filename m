From: Patrick McHardy <kaber@trash.net>
Subject: Re: [build bug] nf_nat_proto_sctp.c:(.text+0x6d173): undefined reference
 to `crc32c_le'
Date: Mon, 21 Apr 2008 13:18:22 +0200
Message-ID: <480C77FE.2040107@trash.net>
References: <20080421062244.GA862@elte.hu>	<20080420.235354.104901823.davem@davemloft.net>	<20080421084402.GF26897@cs181133002.pp.htv.fi> <20080421.015906.239470094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, mingo@elte.hu, linville@tuxdriver.com,
	tomas.winkler@intel.com, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37636 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448AbYDULSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:18:30 -0400
In-Reply-To: <20080421.015906.239470094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Adrian Bunk <bunk@kernel.org>
> Date: Mon, 21 Apr 2008 11:44:02 +0300
> 
>> On Sun, Apr 20, 2008 at 11:53:54PM -0700, David Miller wrote:
>>> From: Ingo Molnar <mingo@elte.hu>
>>> Date: Mon, 21 Apr 2008 08:22:44 +0200
>>>
>>>>   net/built-in.o: In function `sctp_manip_pkt':
>>>>   nf_nat_proto_sctp.c:(.text+0x6d173): undefined reference to `crc32c_le'
>>>>   nf_nat_proto_sctp.c:(.text+0x6d180): undefined reference to `crc32c_le'
>>>>   nf_nat_proto_sctp.c:(.text+0x6d196): undefined reference to `crc32c_le'
>>>>   nf_nat_proto_sctp.c:(.text+0x6d1c6): undefined reference to `crc32c_le'
>>>>
>>>>   http://redhat.com/~mingo/misc/config-Mon_Apr_21_01_52_14_CEST_2008.bad
>>> Thanks for your report Ingo.
>>>
>>> Patrick, I'm not so sure how to fix this, or even what's wrong.
>>>
>>> NF_NAT_PROTO_SCTP does a proper select on LIBCRC32C, but somehow
>>> NF_NAT_PROTO_SCTP=y and LIBCRC32C=m.
>>> ...
>> You added the select on Saturday after Pete Clements reported the same 
>> issue.
>>
>> The select is not yet in Linus' tree.
> 
> Thanks for catching that Adrian.

I've verified that Saturday's patch results in a correct looking
config, with

CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_LIBCRC32C=y

