From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][NETNS] Use list_for_each_entry_continue_reverse in
 setup_net
Date: Fri, 14 Sep 2007 14:49:38 +0200
Message-ID: <20070914144938.3ba643a5@oldman>
References: <46EA3AB4.7060904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46003 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752427AbXINMs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 08:48:59 -0400
In-Reply-To: <46EA3AB4.7060904@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Sep 2007 11:39:32 +0400
Pavel Emelyanov <xemul@openvz.org> wrote:

> I proposed introducing a list_for_each_entry_continue_reverse
> macro to be used in setup_net() when unrolling the failed
> ->init callback.
> 
> Here is the macro and some more cleanup in the setup_net() itself
> to remove one variable from the stack :) Minor, but the code
> looks nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Maybe it is time to just eliminate the init hook from the API.
It has very few users, and there is no reason the setup needed
could be done before or after registering in most cases.
