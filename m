From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2 2/2] vxlan: support ndo_fill_metadata_dst also
 for IPv6
Date: Mon, 7 Dec 2015 11:19:55 +0100
Message-ID: <20151207111955.48821381@griffin>
References: <cover.1449139112.git.jbenc@redhat.com>
	<66ad22ee59eb0a21090ff9e3fcad7faf77b63148.1449139112.git.jbenc@redhat.com>
	<CALnjE+qX=sv2wgT=HQ1kfmxVj1KAWe5rWuEEMeNbDr_seBxLqw@mail.gmail.com>
	<20151204.142838.797312333399556109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775AbbLGKUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 05:20:16 -0500
In-Reply-To: <20151204.142838.797312333399556109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Dec 2015 14:28:38 -0500 (EST), David Miller wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> > Rather than checking IS_ENABLED(CONFIG_IPV6) three separate times, all
> > code can is restructured in one #if #else block by moving the ndst
> > definition to IPv6 local block.
> 
> Agreed, you should be putting variable definitions into the deepest most
> containing scope anyways.  So if you declare 'ndst' inside of the else
> branch you'll be doing that plus decreasing the amount of CPP tests in
> this file.

No problem. I actually had it that way but decided that I didn't like
the #if #else maze. I'll change it and send v3.

 Jiri

-- 
Jiri Benc
