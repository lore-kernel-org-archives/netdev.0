From: Andi Kleen <andi@firstfloor.org>
Subject: hang after "registering protocol family 2" in linux-next
Date: Thu, 1 Jan 2009 05:33:10 +0100
Message-ID: <20090101043310.GA23765@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45711 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbZAAEbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 23:31:34 -0500
Received: from basil.firstfloor.org (p5B3CB581.dip0.t-ipconnect.de [91.60.181.129])
	by one.firstfloor.org (Postfix) with ESMTP id B59491AD0020
	for <netdev@vger.kernel.org>; Thu,  1 Jan 2009 05:45:02 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


FYI,

I booted today's linux-next and I got a hang somewhere in inet_init 
(according to initcalL_debug) after Registering protocol family 2

Haven't investigated further.

-Andi

-- 
ak@linux.intel.com
