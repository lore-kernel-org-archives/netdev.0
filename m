From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: cleanup arp_interval related
 time math
Date: Mon, 05 Aug 2013 12:20:07 -0700 (PDT)
Message-ID: <20130805.122007.920229880103067439.davem@davemloft.net>
References: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153Ab3HETUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:20:09 -0400
In-Reply-To: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sat,  3 Aug 2013 03:50:34 +0200

> Current implementation uses heavily time_in_range() with similar, lengthy,
> params. By moving it to a separate function we can simplify the code a lot.
> 
> First patch saves a possibly heavy slave_last_rx() function to a variable
> and uses the variable in the calculation.
> 
> Second patch introduces helper function bond_time_in_interval() to make the
> arp_interval math and uses it instead of lengthy time_in_range() calls.
> 
> Both of them don't change anything logically and in terms of speed and are
> purely cleanup patches.

Series applied, thanks.
