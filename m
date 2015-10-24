From: David Miller <davem@davemloft.net>
Subject: openvswitch: net --> net-next merge
Date: Sat, 24 Oct 2015 06:55:56 -0700 (PDT)
Message-ID: <20151024.065556.1808313684538753807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joestringer@nicira.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbbJXNjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 09:39:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I needed to do a merge of 'net' into 'net-next' in order to
facilitate a set of tipc patches that I wanted to apply to
'net-next'.

There were several openvswitch merge conflicts, mostly to do with the
egress tunnel info bug fix conflicting with the simplification of the
vport ->send() method.

I did my best to resolve the conflicts, but if someone would double
check my work I would really appreciate it.

Thanks.
