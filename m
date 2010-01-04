From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: Re: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 04 Jan 2010 12:51:22 -0800
Message-ID: <1262638282.8178.257.camel@groeck-laptop>
References: <1262635784.8178.253.camel@groeck-laptop>
	 <20100104122912.5f9d1ebb@nehalam>
Reply-To: guenter.roeck@ericsson.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgate.redback.com ([155.53.3.41]:33604 "EHLO mgate.redback.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844Ab0ADUts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 15:49:48 -0500
In-Reply-To: <20100104122912.5f9d1ebb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, thanks.

Guenter

On Mon, 2010-01-04 at 15:29 -0500, Stephen Hemminger wrote:
> On Mon, 04 Jan 2010 12:09:44 -0800
> Guenter Roeck <guenter.roeck@ericsson.com> wrote:
> 
> > For example, when hashing "eth0" .. "eth9999" with a hash table size of 256,
> > the resulting minimum hash bucket depth is 0, the maximum depth is 563,
> > and the standard deviation is ~136.
> 
> The problem was a missing call to hash_32() on the result, and is
> already fixed in current kernel.
> 

