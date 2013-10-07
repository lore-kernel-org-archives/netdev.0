From: David Miller <davem@davemloft.net>
Subject: Re: bug in passing file descriptors
Date: Mon, 07 Oct 2013 15:42:26 -0400 (EDT)
Message-ID: <20131007.154226.533738557474978526.davem@davemloft.net>
References: <5253061A.7060701@nec-labs.com>
	<20131007.151233.2237348893254566536.davem@davemloft.net>
	<525308C4.1030007@nec-labs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, netdev@vger.kernel.org,
	mtk.manpages@gmail.com, ebiederm@xmission.com
To: sar@nec-labs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab3JGTm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:42:28 -0400
In-Reply-To: <525308C4.1030007@nec-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Rago <sar@nec-labs.com>
Date: Mon, 7 Oct 2013 15:17:24 -0400

> Except when sizeof(long) can change and you need to maintain binary
> compatibility with older applications.  x86 comes to mind as a
> relevant example: used to be 32 bits, but is 64 now.

There is no compatability issue.

32-bit tasks will always see the 4-byte align/length.
64-bit tasks will always see the 8-byte align/length.
