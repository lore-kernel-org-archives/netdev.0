From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Tue, 15 Jul 2003 15:59:30 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030715.155930.65250697.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0307141300520.5140-100000@DYN318430.beaverton.ibm.com>
	<200307150117.FAA06705@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307150117.FAA06705@dub.inr.ac.ru>
List-Id: netdev.vger.kernel.org

In article <200307150117.FAA06705@dub.inr.ac.ru> (at Tue, 15 Jul 2003 05:17:53 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> Hello!
> 
> > inet6_fill_ifaddr (and introduce RTM_IFACEFLAGS). This will be specific to
> > IPv6. Are you agreeable to this ?
> ...
> > +	IFA_IFFLAGS,
> 
> What's about ifa_flags? There is some space there, and the things
> kept there now: TENTATIVE/DEPRECATED et al. are close relatives
> of O/M.

Alexey, O/M are not flags for addresses, but for interfaces.
I believe we should not mix them up.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
