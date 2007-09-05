From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [RFC] allow admin/users to specify rto_min in
 milliseconds rather than jiffies
Date: Wed, 5 Sep 2007 07:38:01 +0100
Message-ID: <20070905073801.2f12991b@oldman>
References: <200709042020.NAA29612@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:32829 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752445AbXIEGhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 02:37:19 -0400
In-Reply-To: <200709042020.NAA29612@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Sep 2007 13:20:47 -0700 (PDT)
Rick Jones <rick.jones2@hp.com> wrote:

> Build upon David Miller's initial patches to set the per-route rto_min
> so users can specify the rto_min in the same units (milliseconds) in
> which they are displayed.  This is desirable because asking users to
> convert to and from jiffies themselves, when there can be different
> values of HZ from system to system would be error prone.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> ---

The api in netlink should be in milliseconds rather than compensating
in the application (iproute2).
