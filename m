From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFCv2 net-next 6/7] net: Refactor ip_defrag() APIs
Date: Tue, 3 Mar 2015 08:20:54 +0000
Message-ID: <20150303082054.GA11110@acer.localdomain>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
 <1425333305-19702-7-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>, linux-kernel@vger.kernel.org,
	Justin Pettit <jpettit@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40446 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbbCCIU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 03:20:59 -0500
Content-Disposition: inline
In-Reply-To: <1425333305-19702-7-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.03, Joe Stringer wrote:
> From: Andy Zhou <azhou@nicira.com>
> 
> Currently, ip_defrag() does not keep track of the maximum fragmentation
> size for each fragmented packet. This information is not necessary since
> current Linux IP fragmentation always fragments a packet based on output
> devices' MTU.

It does, search for max_size.
