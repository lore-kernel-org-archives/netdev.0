From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Thu, 27 May 2004 08:08:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527.080828.06774575.yoshfuji@linux-ipv6.org>
References: <20040526132215.06e0bc12.davem@redhat.com>
	<OFD49A843C.7EDA1DE2-ON87256EA0.0071A2A0-07256EA0.0071C18B@us.ibm.com>
	<20040526134415.483a6384.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040526134415.483a6384.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040526134415.483a6384.davem@redhat.com> (at Wed, 26 May 2004 13:44:15 -0700), "David S. Miller" <davem@redhat.com> says:

> On Wed, 26 May 2004 13:42:23 -0700
> Shirley Ma <xma@us.ibm.com> wrote:
> 
> > Yes, same structure ip_stats applys to IPv4 as well.
> 
> Great, patch applied.

I failed to comment because I've just waken up...

Hmm, why are you so hurrying?
It on -rc stage and 2.6.7 is coming.
Each people should moderate yourself...

Sorry, please exclude it for now.

Comments:

Without adding support for u64 counter, it does not make sense to add
new interface. You can add new counter to the end of the structures.

This also contains per-interface statistics support.
(I rember that you said that) we should add idev into an route and avoid
get/put idev.

I strongly do not want to poeple to change their code twice to support
draft-ietf-ipv6-rfc2011-update-XX.txt.

I personally think this should be included in 2.7 phase.

--yoshfuji @ morning
