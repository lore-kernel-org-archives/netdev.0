From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tipc: fix undefined __ipv6_sock_mc_join
 compile error
Date: Tue, 10 Mar 2015 12:47:42 -0400 (EDT)
Message-ID: <20150310.124742.2005589544373604240.davem@davemloft.net>
References: <1425976885-18258-1-git-send-email-ying.xue@windriver.com>
	<CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbbCJQrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:47:45 -0400
In-Reply-To: <CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 10 Mar 2015 11:41:03 -0400

> On Tue, Mar 10, 2015 at 4:41 AM, Ying Xue <ying.xue@windriver.com> wrote:
>> @@ -5,6 +5,7 @@
>>  menuconfig TIPC
>>         tristate "The TIPC Protocol"
>>         depends on INET
>> +       depends on (IPV6 || IPV6=n)
> 
> Should this be limited to TIPC_MEDIA_UDP?

I think it should.
