From: Daniele Orlandi <daniele@orlandi.com>
Subject: Re: Request for an ARPHRD_
Date: Mon, 24 Oct 2005 23:33:04 +0200
Message-ID: <200510242333.05366.daniele@orlandi.com>
References: <200510240255.28416.daniele@orlandi.com> <200510241807.23290.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@vger.kernel.org
In-Reply-To: <200510241807.23290.ak@suse.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 24 October 2005 18:07, Andi Kleen wrote:
>
> ETH_P_* is managed by the IEEE (part of the ethernet standard) You would
> need to ask them.

I need a pseudo protocol like it is already done for some internal protocol, 
e.g.:

/*
 *      Non DIX types. Won't clash for 1500 types.
 */
[.....]
#define ETH_P_WAN_PPP   0x0007          /* Dummy type for WAN PPP frames*/
#define ETH_P_PPP_MP    0x0008          /* Dummy type for PPP MP frames */
#define ETH_P_LOCALTALK 0x0009          /* Localtalk pseudo type        */
#define ETH_P_PPPTALK   0x0010          /* Dummy type for Atalk over PPP*/
[....]

> Normally Linux doesn't pre-allocate ABIs for out of tree code, mostly
> because it is not guaranteed that the interface won't change there.

Could you clarify? What interface do you fear that could change?

My main concern is that without an ARPHRD_ constant guaranteed to be unique I 
wouldn't be able to propose a patch for libpcap people to map the (already 
allocated) DLT_ to the correct ARPHRD_.

Bye,

-- 
  Daniele Orlandi
