From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc_act: export all user headers
Date: Mon, 25 Apr 2016 16:52:44 -0400 (EDT)
Message-ID: <20160425.165244.795853255564768080.davem@davemloft.net>
References: <20160422100638.4f4280bf@xeon-e3>
	<20160425.164939.2072274531689250224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@mojatatu.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964855AbcDYUwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:52:46 -0400
In-Reply-To: <20160425.164939.2072274531689250224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 25 Apr 2016 16:49:39 -0400 (EDT)

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Fri, 22 Apr 2016 10:06:38 -0700
> 
>> The file tc_ife.h was missing from the export list.
>> Rather than continue to cherry-pick, just export all headers in the directory.
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Applied.

Please compile test, pretty please??!?!?

./usr/include/linux/tc_act/*.h: No such file or directory

It looks like you can't expect shell expansions like that to work in
Kbuild files.
