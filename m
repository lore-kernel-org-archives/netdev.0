From: Ben Collins <benmcollins13@gmail.com>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 10:43:44 -0400
Message-ID: <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com> <20130322.101139.1942128058226201237.davem@davemloft.net> <A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com> <20130322.103302.1277256650283142022.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: afleming@freescale.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130322.103302.1277256650283142022.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mar 22, 2013, at 10:33 AM, David Miller <davem@davemloft.net> wrote:

> From: Fleming Andy-AFLEMING <afleming@freescale.com>
> Date: Fri, 22 Mar 2013 14:31:50 +0000
> 
>> It would appear one of our customers is attempting to upstream our
>> code for us. We are aware that this current solution is unacceptable
>> (which is why we have not submitted it), and we are currently trying
>> to develop a less hacky solution that integrates with qdisc.
> 
> Ben, can can you coordinate with people instead of doing crap like
> this?


"For us" is a loose term, when it's more that we are attempting to upstream code so our system is supported by a mainline kernel instead of having one-off kernels.

And we have been talking with Freescale about this for quite some time (couple years?). They have a roadmap that doesn't include getting this driver supported in mainline any time soon, so I'm taking time to get this done for our own system. I'm not meaning to step on any toes.

Believe me, I've attempted to make this as painless as possible. Only having 5 patches (and each just a few lines) is significantly less than how this driver started out. I can toss out the QDisc patch and work on a better way. I'm not totally familiar with the queueing, so any pointers to a better way to handle this would be appreciated.

--
Servergy  : http://www.servergy.com/
SwissDisk : http://www.swissdisk.com/
Ubuntu    : http://www.ubuntu.com/
My Blog   : http://ben-collins.blogspot.com/
