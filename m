From: Anatoly Pugachev <mator@gsib.ru>
Subject: small e100 ethernet driver problem -> %d
Date: Tue, 20 May 2003 18:03:41 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520140341.GY30683@gsib.sl.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!
using linux kernel 2.5.69
trying to load e100 driver, gives me following in logs:
May 20 16:47:56 p4 kernel: Intel(R) PRO/100 Network Driver - version
2.2.21-k1
May 20 16:47:56 p4 kernel: Copyright (c) 2003 Intel Corporation
May 20 16:47:56 p4 kernel:
May 20 16:47:56 p4 kernel: e100: selftest OK.
May 20 16:47:59 p4 kernel: Freeing alive device d2c43800, eth%%d
May 20 16:47:59 p4 kernel: e100: eth1: Intel(R) PRO/100 Network Connection
May 20 16:47:59 p4 kernel:   Hardware receive checksums enabled
May 20 16:47:59 p4 kernel:   cpu cycle saver enabled

module works fine, but notice %%d in the output, should be missprint and
easy to fix.

-- 
/mator
