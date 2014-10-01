From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 13:43:04 -0400
Message-ID: <542C3D28.6050705@oracle.com>
References: <20141001151921.7131E29003A2@tardy> <542C23AA.6060505@oracle.com> <542C2CAB.2030501@hp.com> <542C32E6.7080106@oracle.com> <542C3A95.8050804@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38388 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaJARnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 13:43:11 -0400
In-Reply-To: <542C3A95.8050804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/2014 01:32 PM, Rick Jones wrote:

> It would be an added statistic for "ignored" UDP multicast datagrams, incremented instead of UDP_MIB_NOPORTS.  "UDP_MIB_IGNOREDMULTI" if you will.
> 
> Similar in concept to what HP-UX NIC drivers would increment when they received a frame for which there was no bound protocol - "inbound unknown protocols" but not a drop
> http://ptgmedia.pearsoncmg.com/images/chap1_0130428167/elementLinks/01fig16.gif

I guess I'm ok with that.

Ideally, it wouldn't be affected by running a sniffer, so I think best would be to increment
NOPORTS when someone has joined the group on the interface and IGNOREDMULTI when nobody has,
but I'm not sure it's worth the trouble to check. So I'm good with that, or IGNOREDMULTI all
the time.

								+-DLS
