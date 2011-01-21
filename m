From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH v2 0/2] tlan improvements
Date: Fri, 21 Jan 2011 22:59:19 +0200
Message-ID: <4D39F3A7.9050106@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Samuel Chessman <chessman@tux.org>, Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:49050 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab1AUU7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 15:59:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is the second version of the tlan improvements patchset.

This patchset cleans up the tlan driver code and adds suspend/resume 
support. The changes in coding style are big. There's one checkpatch.pl 
warning left.

The last patch, which is the biggest usability improvement to the tlan 
driver in this set, brings suspend/resume support. I lended a few bits 
from the e100 driver which I know has received more attention from 
developers over the years. That, I believe, is the only non-trivial 
change in the set.

Changes since v1:

The second patch has been dropped. Ben Hutchings pointed out that 
instead of fixing the prints ethtool interface should be supported. I 
have not time to do that right now and I would like the cleanup and 
possibly also suspend/resume support in without that.

Cheers,

-- 
Sakari Ailus
sakari.ailus@iki.fi
