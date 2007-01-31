From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] cxgb3 - FW versioning
Date: Wed, 31 Jan 2007 05:40:02 -0500
Message-ID: <45C07202.3090308@garzik.org>
References: <20070131034345.8574.21031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <None@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55604 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932965AbXAaKkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:40:04 -0500
In-Reply-To: <20070131034345.8574.21031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You need to submit a patch to remove the following ioctls:

CHELSIO_SETREG:
CHELSIO_GETREG:
CHELSIO_SET_QSET_PARAMS: (use ethtool instead)
CHELSIO_GET_QSET_PARAMS: (use ethtool instead)
CHELSIO_SET_QSET_NUM: (use ethtool instead)
CHELSIO_GET_QSET_NUM: (use ethtool instead)
CHELSIO_SETMTUTAB:
CHELSIO_GET_MEM:
CHELSIO_SET_TRACE_FILTER:
CHELSIO_SET_PKTSCHED:

explain and possibly remove

CHELSIO_GET_PM:
CHELSIO_SET_PM:

honestly it looks like just about every ioctl except load-firmware should go


