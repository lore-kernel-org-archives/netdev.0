From: Ferenc Wagner <wferi@niif.hu>
Subject: Is CONFIG_IP_VS_IPV6 still/really dangerous?
Date: Fri, 04 Jun 2010 15:56:16 +0200
Message-ID: <87631y3nr3.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:37894 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab0FDOUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 10:20:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In commit fab0de02fb0da83b90cec7fce4294747d86d5c6f CONFIG_IP_VS_IPV6 is
described as:

    Add IPv6 support to IPVS. This is incomplete and might be dangerous.

I agree its implementation is incomplete.  But I wonder if it's really
dangerous in the sense that generic distribution kernels shouldn't
enable it, because it can break unrelated (eg. IPv4 IPVS) functionality.

What does that warning mean today?  Isn't it out of date?
-- 
Thanks,
Feri.
