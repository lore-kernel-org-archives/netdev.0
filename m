From: Phil Oester <kernel@linuxace.com>
Subject: Re: [RFC][PATCH 2/2] ip multipath, bk head (EXPERIMENTAL)
Date: Tue, 14 Sep 2004 08:08:32 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040914150832.GA5667@linuxace.com>
References: <41457848.6040808@de.ibm.com> <1095129624.1060.45.camel@jzny.localdomain> <20040913224232.4b979c7d.davem@davemloft.net> <4146E65D.6070309@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269410AbUINPMq@vger.kernel.org>
To: lkml@einar-lueck.de
Content-Disposition: inline
In-Reply-To: <4146E65D.6070309@de.ibm.com>
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2004 at 02:38:53PM +0200, Einar Lueck wrote:
> I attached the patch the way you requested in the other thread.
> 
> Regards
> Einar

		If you say Y here, alternative routes are cached
+         in the routing cache and on cache lookup route is chosen in
+         Round Robin fashon.            

Shouldn't this instead say

If you say Y here, alternative routes are cached
in the routing cache and on cache lookup a route is chosen using
the policy selected in 'Multipath policy'

or somesuch.  IOW, round robin is not always the policy.

Phil
