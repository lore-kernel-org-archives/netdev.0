From: jpo234@netscape.net
Subject: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Thu, 15 Jan 2009 08:15:50 -0500
Message-ID: <8CB452A85703FEF-9E4-FEB@FWM-M04.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m21.mx.aol.com ([64.12.137.2]:64886 "EHLO
	imo-m21.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755703AbZAONYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 08:24:08 -0500
Received: from jpo234@netscape.net
	by imo-m21.mx.aol.com  (mail_out_v39.1.) id x.d01.489a94a5 (37530)
	 for <netdev@vger.kernel.org>; Thu, 15 Jan 2009 08:15:57 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
the IPv4 socket interface had the nifty IP_HDRINCL option. It seems 
that an IPv6 version of this option is not available. The proposed 
solution for this seems to be to use libpcap to inject the packet. 
Unfortunately this completely bypasses both, netfilter and IPsec. So, 
am I lost or is there a way to do what I want/need?

Thanks in advance
   Joerg
