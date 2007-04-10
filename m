From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.21 0/3] cxgb3 - bug fixes
Date: Mon, 09 Apr 2007 20:09:57 -0700
Message-ID: <461B0005.7070801@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:23640 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932886AbXDJDKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 23:10:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a set of bug fixes for inclusion in 2.6.21.
The patches are built against Linus'git tree.

Here is a brief description:
- Avoid deadlock when the interface is brought down
- Rework the MAC hang workaround since it was failing
  if the peer interface was brought down
- add missing RNIC register setting and CPL handler

Cheers,
Divy
