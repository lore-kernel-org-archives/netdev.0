From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 1/2] drivers: net: cpsw: Add helper functions for VLAN ALE implementation
Date: Thu, 31 Jan 2013 22:43:06 +0100
Message-ID: <20130131214306.GA18739@electric-eye.fr.zoreil.com>
References: <1359572855-12344-1-git-send-email-mugunthanvnm@ti.com> <1359572855-12344-2-git-send-email-mugunthanvnm@ti.com> <20130130220208.GA22847@electric-eye.fr.zoreil.com> <510A50DE.1010308@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <510A50DE.1010308@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mugunthan V N <mugunthanvnm@ti.com> :
> On 1/31/2013 3:32 AM, Francois Romieu wrote:
[...]
> > It could be factored out.
> Are you mentioning to have static inline function for the above two
> statements above?

Yes. The helper function does not need to be inlined if it does not
save space: this path is not performance critical.

[...]
> >Patch #2 doesn't use the returned status code.
> Will modify the prototype to return void

:o(

The driver should notify the upper layers that the request failed instead
of hiding the stuff under the carpet.

-- 
Ueimor
