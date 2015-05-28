From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net v2] openvswitch: disable LRO
Date: Thu, 28 May 2015 10:21:17 -0300
Message-ID: <20150528132117.GA3172@x240.home>
References: <cf405251e71318f7c7f8ddac07919acb8c28232e.1432818254.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender1.zohomail.com ([74.201.84.157]:24032 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752615AbbE1NVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 09:21:22 -0400
Content-Disposition: inline
In-Reply-To: <cf405251e71318f7c7f8ddac07919acb8c28232e.1432818254.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 03:04:53PM +0200, Jiri Benc wrote:
> Currently, openvswitch tries to disable LRO from the user space. This does
> not work correctly when the device added is a vlan interface, though.
> Instead of dealing with possibly complex stacked cross name space relations
> in the user space, do the same as bridging does and call dev_disable_lro in
> the kernel.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
LGTM
Acked-by: Flavio Leitner <fbl@redhat.com>
