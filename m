From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: clear IFF_TX_SKB_SHARING
Date: Wed, 17 Feb 2016 10:53:32 +0100
Message-ID: <20160217105333.7e463b21@griffin>
References: <ad978a069caa3c84931b9f0eca7a268f9b459963.1455656611.git.jbenc@redhat.com>
	<CAEh+42hjEfke5jgxWWQENWRn1G-uycar+n-8Y9EQ90Bv6OTgZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933837AbcBQJxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 04:53:36 -0500
In-Reply-To: <CAEh+42hjEfke5jgxWWQENWRn1G-uycar+n-8Y9EQ90Bv6OTgZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Feb 2016 16:04:33 -0800, Jesse Gross wrote:
> Presumably this is something that should be done on all tunnels that
> can carry Ethernet frames, right?

Geneve and GRE likely need the same fix, yes. I think the fixes for
them should be sent as separate patches.

 Jiri

-- 
Jiri Benc
