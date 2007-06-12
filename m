From: Jens Axboe <jens.axboe@oracle.com>
Subject: [PATCH 0/3] Splice network receive support
Date: Tue, 12 Jun 2007 09:03:57 +0200
Message-ID: <1181631840469-git-send-email-jens.axboe@oracle.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:17203 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759428AbXFLHGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 03:06:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This series of patches applies on top of the splice series just
posted. It implements basic network receive support, ie splicing
from a socket to a pipe.

There seems to be a skhead_buff_cache leak somewhere that I need
to track down, otherwise it works fine for me.

-- 
Jens Axboe


