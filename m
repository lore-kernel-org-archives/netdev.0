From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Subject: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss command
Date: Wed, 4 Apr 2012 18:03:11 +0900
Message-ID: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
Move the sock_ code to net/core/"), ss command from iproute package
doesn't work if INET_DIAG is not enabled.

$ ss
State       Recv-Q Send-Q                                             Local Address:Port                                                 Peer Address:Port
TCPDIAG answers: Operation not supported
