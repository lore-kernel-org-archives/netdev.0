From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/5] bonding: convert to list API and replace
 bond's custom list
Date: Wed, 31 Jul 2013 11:38:49 -0700
Message-ID: <20130731113849.02746040@nehalam.linuxnetplumber.net>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
	<1375283553-32070-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	fubar@us.ibm.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37348 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760651Ab3GaSix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 14:38:53 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so1172306pad.23
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 11:38:52 -0700 (PDT)
In-Reply-To: <1375283553-32070-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Jul 2013 17:12:29 +0200
Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> -	bond_for_each_slave(bond, tmp, i)
> +	list_for_each_entry(tmp, &bond->slave_list, list)

It would be nice to keep the wrapper macro's bond_for_each_slave
and introduce a bond_for_each_slave_rcu() for the cases where you
are using RCU.
