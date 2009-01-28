From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 0/21] Reliable Datagram Sockets (RDS)
Date: Wed, 28 Jan 2009 14:37:25 -0800
Message-ID: <adaskn3ukey.fsf@cisco.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:5130 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbZA1Wh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 17:37:27 -0500
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> (Andy
	Grover's message of "Mon, 26 Jan 2009 18:17:37 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > This patchset adds support for RDS as an Infiniband ULP. RDS is an
 > Oracle-originated protocol used to send IPC datagrams (up to 1MB) reliably,
 > and is used currently in Oracle RAC and Exadata products. It's lived
 > in OFED for 2+ years and I think it's time to get it upstream -- most
 > likely into your -next tree for .30, but if it snuck into .29 via the
 > "new code merge-window exception" then even better.

I'll read this over and comment, but to be honest I agree with Dave:
this is a new socket family, and as such it belongs under net/ and
probably should go through Dave's tree (just as the NFS/RDMA changes
went through the NFS trees and the 9p/RDMA changes went through the 9p
tree); even though it heavily uses RDMA I think the upper layer
interface to sockets/networking is more relevant.

 - R.
