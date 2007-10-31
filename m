From: Rick Jones <rick.jones2@hp.com>
Subject: Re: recent sysfs changes cause lots of network device errors
Date: Tue, 30 Oct 2007 17:02:53 -0700
Message-ID: <4727C62D.2000300@hp.com>
References: <20071030150010.79253f01@freepuppy.rosehill> <20071030224043.GA6612@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Kay Sievers <kay.sievers@vrfy.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:41077 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbXJaACz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 20:02:55 -0400
In-Reply-To: <20071030224043.GA6612@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Well, this was a bug that no one caught in -mm as we all seem to be
> running with CONFIG_SYSFS_DEPRECATED disabled.  There was a long
> discussion on lkml last week, and here's the patch that should fix it
> that is going to Linus in a day or so (it's in my tree, but I'm supposed
> to be on vacation right now...)
> 
> Let me know if this works for you or not.

I don't know if it worked for Stephen, but it certainly worked to get rid of the 
last three rename-induced stack traces on my system.

rick jones
