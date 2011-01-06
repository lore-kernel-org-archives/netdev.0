From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 0/3] tlan improvements
Date: Thu, 06 Jan 2011 20:49:52 +0200
Message-ID: <4D260ED0.5040301@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:52992 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab1AFS7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:59:12 -0500
Received: from hillosipuli.localdomain (nblzone-211-213.nblnetworks.fi [83.145.211.213])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-68.nebula.fi (Postfix) with ESMTP id A0DA643F0893
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:49:52 +0200 (EET)
Received: from [192.168.1.1] (masiina.localdomain [192.168.1.1])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hillosipuli.localdomain (Postfix) with ESMTPS id 83D7C6009B
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:49:51 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The time has come, again after two years, for me to hack on the tlan 
driver again.

I realised it did not have suspend/resume support.

This patchset cleans up the tlan driver code and adds suspend/resume 
support. The changes in coding style are big. There's one checkpatch.pl 
warning left.

The last patch, which is the biggest improvement to the tlan driver in 
this set, brings suspend/resume support. I lended a few bits from the 
e100 driver which I know has received more attention from developers 
over the years. That, I believe, is the only non-trivial change in the set.

Cheers,

-- 
Sakari Ailus
sakari.ailus@iki.fi
