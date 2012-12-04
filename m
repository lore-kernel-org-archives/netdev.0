From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] vxlan: Fix error that was resulting in VXLAN MTU size
 being 10 bytes too large
Date: Tue, 04 Dec 2012 09:12:22 -0800
Message-ID: <50BE2EF6.8060005@intel.com>
References: <20121119080351.477525b3@nehalam.linuxnetplumber.net> <CAOzFzEh0X3CcjBYWVDAtu7=jRSc1_P2OQSF_YWjnBSeugo3W6A@mail.gmail.com> <20121204094809.9689.C42C3789@sakura.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joseph Glanville <joseph.glanville@orionvm.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65352 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593Ab2LDRMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:12:30 -0500
In-Reply-To: <20121204094809.9689.C42C3789@sakura.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2012 04:48 PM, Naoto MATSUMOTO wrote:
> 
> Hi all
> 
> Sharing my testlab resut for you ;-)
> 
> A First Look At VXLAN over Infiniband Network On Linux 3.7-rc7
> http://slidesha.re/TsCKWc
> 
> plz enjyoi it.
> 
> --
> Naoto

What was the MTU for the underlying IPoIB devices in your test?  Just
wondering because the MTU on the VXLAN is showing as 65470 which would
imply the IPoIB devices should have a 65520 MTU and I just wanted to
confirm that.

Thanks,

Alex
