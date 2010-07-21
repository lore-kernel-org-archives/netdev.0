From: Daniel Wagner <wagi@monom.org>
Subject: CONNMARK getsockopt/setsockopt functionality
Date: Wed, 21 Jul 2010 09:20:06 +0200
Message-ID: <20100721072006.GA17965@pc0043.bmw-carit.intra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from toronto053.server4you.de ([62.75.220.53]:54155 "EHLO
	toronto053.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762781Ab0GUH3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 03:29:46 -0400
Received: from localhost (mail.bmw-carit.de [62.245.222.98])
	(Authenticated sender: wagi)
	by toronto053.server4you.de (Postfix) with ESMTPSA id 5B3EA54049
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 07:20:11 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There used to be a way to mark packets in userspace by invoking the
setsocketopt with SO_CONNMARK as it was proposed by Krisztian [1].
This code was superseeded by Jan's work [2]. Now I wonder how I get
the same result out of the new code. Something with conditions? 

thanks,
daniel

[1] http://lists.netfilter.org/pipermail/netfilter-devel/2004-May/015385.html
[2] http://www.kerneltrap.com/mailarchive/git-commits-head/2009/9/14/4291
