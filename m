From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Tue, 15 Aug 2006 03:27:40 -0700 (PDT)
Message-ID: <20060815.032740.10248213.davem@davemloft.net>
References: <20060815002724.a635d775.akpm@osdl.org>
	<p738xlqa0aw.fsf@verdi.suse.de>
	<20060815100228.GC1092@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49034
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965363AbWHOK1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 06:27:39 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060815100228.GC1092@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 15 Aug 2006 14:02:28 +0400

> I had a version with per-cpu data - it is not very convenient to use
> here with it's per_cpu_ptr dereferencings....

It does eat lots of space though, even for non-present cpus, and for
local cpu case the access may even get optimized to a single register
+ offset computation on some platforms :-)
