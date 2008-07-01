From: Philippe Troin <phil@fifi.org>
Subject: (!sk->sk_forward_alloc) assertation failure in 2.6.25.6
Date: 01 Jul 2008 11:18:43 -0700
Message-ID: <871w2dtqm4.fsf@old-tantale.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from old-tantale.fifi.org ([64.81.30.200]:36335 "EHLO
	old-tantale.fifi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbYGASuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 14:50:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dmesg excerpt:

nfsd: last server has exited
nfsd: unexporting all filesystems
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (157)
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
nfsd: last server has exited
nfsd: unexporting all filesystems
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period

As reported in:

  http://kerneltrap.org/mailarchive/linux-netdev/2008/6/21/2189804 

the NFS server was restarting when the error occurred.

Phil.
