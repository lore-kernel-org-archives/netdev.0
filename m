From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/9] net: Fix up inet_addr_type checks
Date: Tue, 11 Aug 2015 11:51:53 -0700 (PDT)
Message-ID: <20150811.115153.841476832505171489.davem@davemloft.net>
References: <1439229037-79213-7-git-send-email-dsa@cumulusnetworks.com>
	<20150811.111457.652499160223100513.davem@davemloft.net>
	<55CA3C6C.5010606@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, svaidya@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbbHKSvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:51:55 -0400
In-Reply-To: <55CA3C6C.5010606@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 11 Aug 2015 12:18:20 -0600

> The intent here was to default to current behavior and to keep the
> details of that in one place. If you prefer table id to always enter
> with the right value I can make that happen.

I think it looks better that way.

People reading individual pieces of code can tell what is happening
much more easily.

As currently structured, the have to know the internal details of a
helper function to understand what '0' means.
