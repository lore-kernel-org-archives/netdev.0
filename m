From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: check kern before calling security subsystem
Date: Thu, 05 Nov 2009 21:08:03 -0800 (PST)
Message-ID: <20091105.210803.63946241.davem@davemloft.net>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
	<20091104163224.27133.88570.stgit@paris.rdu.redhat.com>
	<20091104173220.GH2603@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	dwalsh@redhat.com, linux-security-module@vger.kernel.org
To: acme@infradead.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091104173220.GH2603@ghostprotocols.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@infradead.org>
Date: Wed, 4 Nov 2009 15:32:20 -0200

> Em Wed, Nov 04, 2009 at 11:32:24AM -0500, Eric Paris escreveu:
>> Before calling capable(CAP_NET_RAW) check if this operations is on behalf
>> of the kernel or on behalf of userspace.  Do not do the security check if
>> it is on behalf of the kernel.
>> 
>> Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-next-2.6
