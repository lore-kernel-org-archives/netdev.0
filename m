From: Jiri Pirko <jiri@resnulli.us>
Subject: perm_addr get
Date: Fri, 21 Dec 2012 14:01:27 +0100
Message-ID: <20121221130127.GB2040@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:58223 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab2LUNBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 08:01:31 -0500
Received: by mail-ea0-f182.google.com with SMTP id a14so1917827eaa.13
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 05:01:30 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

>From what I understand dev->perm_addr is set only in case the hw has
permanent hw address somewhere written (for example EPROM).

So when I query device which does not have perm_addr set I get:

testt1:~$ ethtool -P team0
Permanent address: 00:00:00:00:00:00

Is this the correct behaviour? Wouldn't it be more correct if
ethtool_get_perm_addr() fails with -ENOENT for something like that?

Thanks.

Jiri
