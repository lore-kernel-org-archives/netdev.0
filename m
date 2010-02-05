From: "Kevin Pedretti" <ktpedre@sandia.gov>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Thu, 4 Feb 2010 17:36:54 -0700
Message-ID: <1265330214.23523.78.camel@hawkeye.sandia.gov>
References: <1265160242.15726.20.camel@hawkeye.sandia.gov>
 <20100202.174045.135005544.davem@davemloft.net>
 <1265324464.23523.51.camel@hawkeye.sandia.gov>
 <20100204.151357.18104114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100204.151357.18104114.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-02-04 at 16:13 -0700, David Miller wrote:
> From: "Kevin Pedretti" <ktpedre@sandia.gov>
> Date: Thu, 4 Feb 2010 16:01:04 -0700
> 
> > Please let me know if these issues are show-stoppers as far as inclusion
> > goes.  We would like to get this open-source driver into the kernel so
> > us and others with Cray XT systems can start to benefit from it, and
> > continue to automatically track kernel API changes. 
> 
> I may let it in as-is, thanks for the explanations.
> 
> Could you at least consider perhaps that since it isn't
> really ethernet, not pretending that it is may be something
> to look at?

Sure, I'm open to doing this and would appreciate any example drivers
you could point me at.  We do need to keep the capability though of
talking to Cray's existing proprietary "ethernet" over seastar driver,
which the existing driver does.  If we go this route of being a
non-Ethernet device, do you think it would still be possible to support
this?

Kevin
