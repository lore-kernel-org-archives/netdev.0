From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2 net-next 05/10] qede: Add basic network device support
Date: Thu, 24 Sep 2015 22:56:37 -0700 (PDT)
Message-ID: <20150924.225637.783498142122739755.davem@davemloft.net>
References: <1442499839-22762-6-git-send-email-Yuval.Mintz@qlogic.com>
	<20150924142536.052d6175@urahara>
	<B5657A6538887040AD3A81F1008BEC63E32A5E@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com, Sudarsana.Kalluru@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965AbbIYF4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 01:56:38 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63E32A5E@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Fri, 25 Sep 2015 05:43:06 +0000

>> > +struct qede_rx_queue {
>> > +	__le16			*hw_cons_ptr;
>> 
>> The __ variants of constants should be reserved for use in user visible API's
> 
> Really? If so, this needs to be fixed not only here but in lots of places
> in the series [e.g., entire HW HSI uses __le variants instead of le].
> But why is it so? I.e., I understand that __le16 is defined in the uapi directory and
> thus accessible to users, but why the distinction?

Because it shows whether the type is something exposed to userspace or not.

If there are places where this is done incorrectly in the tree, it is not
a legitimate reason for you to do so as well.
