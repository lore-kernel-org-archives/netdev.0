From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Fixing a bug in team driver due to incorrect
 'unsigned int' to 'int' conversion
Date: Thu, 06 Oct 2016 01:19:50 -0400 (EDT)
Message-ID: <20161006.011950.406052415167344815.davem@davemloft.net>
References: <3444639.ILgt5kU9OR@zbook>
        <1475636928.28155.196.camel@edumazet-glaptop3.roam.corp.google.com>
        <2440068.EFRMUI8i5V@zbook>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexandre.sidorenko@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbcJFFTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 01:19:55 -0400
In-Reply-To: <2440068.EFRMUI8i5V@zbook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Date: Wed, 05 Oct 2016 09:06:04 -0400

> Roundrobin runner of team driver uses 'unsigned int' variable to count the number of sent_packets.
> Later it is passed to a subroutine team_num_to_port_index(struct team *team, int num) as
> 'num' and when we reach MAXINT (2**31-1), 'num' becomes negative.
> 
> This leads to using incorrect hash-bucket for port lookup and as a result, packets are dropped. The fix
> consists of changing 'int num' to 'unsigned int num'. Testing of a fixed kernel shows that there
> is no packet drop anymore.
> 
> 
> Signed-off-by: Alex Sidorenko <alexandre.sidorenko@hpe.com>

This patch has been corrupted by your email client, for example it
has transformed TAB charactes into spaces.

Please fix this up, email a test patch to yourself, and only resubmit
this patch to the mailing list when you are able to successfully apply
the test patch you send to yourself.

Thanks.
