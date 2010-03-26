From: Mattias =?utf-8?Q?R=C3=B6nnblom?= <hofors@lysator.liu.se>
Subject: ip6_dst_dev for IPv4
Date: Fri, 26 Mar 2010 17:59:47 +0100
Message-ID: <871vf76mt8.fsf@isengard.friendlyfire.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lysator.liu.se ([130.236.254.3]:50058 "EHLO
	mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab0CZR25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 13:28:57 -0400
Received: from mail.lysator.liu.se (localhost [127.0.0.1])
	by mail.lysator.liu.se (Postfix) with ESMTP id 8260040012
	for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 17:59:47 +0100 (CET)
Received: from fritz.lysator.liu.se (fritz.lysator.liu.se [130.236.254.179])
	by mail.lysator.liu.se (Postfix) with ESMTP id 4523E4002B
	for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 17:59:47 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm implemeting per-interface SNMP-style network statistics for IPv4,
just like what already exists in the current kernel for IPv6
(/proc/net/dev_snmp6).

For output packets one needs to determine the output interface, and
the v6 statistics uses the ip6_dst_idev() function (ip6_fib.h). I
can't seem to find a corresponding function for IPv4. Is there?

Would someting like:
struct in_device* out_dev = in_dev_get(skb_dst(skb)->dev);
work?

Best regards,
     Mattias

