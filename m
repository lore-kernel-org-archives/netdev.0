From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix -ENOMEM result with invalid user space
 pointer in sendto() syscall
Date: Mon, 26 Nov 2012 17:34:56 -0500 (EST)
Message-ID: <20121126.173456.681656925010309957.davem@davemloft.net>
References: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
	<50B38339.40105@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tt.rantala@gmail.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, sri@us.ibm.com,
	davej@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756271Ab2KZWfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:35:00 -0500
In-Reply-To: <50B38339.40105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 26 Nov 2012 09:56:57 -0500

> On 11/22/2012 08:23 AM, Tommi Rantala wrote:
>> Consider the following program, that sets the second argument to the
>> sendto() syscall incorrectly:
 ...
>> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
> 
> Looks good
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

I'll apply this after the other SCTP fix is respun, because there
is a dependency.
