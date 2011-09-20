From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: macvtap: convert to SKB paged frag API.
Date: Tue, 20 Sep 2011 12:17:24 +0300
Message-ID: <20110920091724.GA11100@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:47848 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab1ITJRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 05:17:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ian,

There is a problem in d1b08284ade "macvtap: convert to SKB paged frag
API."  It removes the initialization of "f" in zerocopy_sg_from_iovec()
which breaks it and causes a compile warning:
drivers/net/macvtap.c:509:5: warning: =E2=80=98f=E2=80=99 may be used u=
ninitialized
	in this function [-Wuninitialized]

regards,
dan carpenter
