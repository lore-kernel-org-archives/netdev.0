From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 0/5] drivers: net: usb: rtl8150: bug fixing and code
 cleanup
Date: Sat, 18 May 2013 23:20:36 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305182305110.16874@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

This patch series adds rtl8150.h, which contains structure and constant 
definitons formerly found in rtl8150.c, removes socket buffer 
pre-allocated pool and uses dynamically allocated memory for the 
asynchronous URB requests, thus avoids clobbering the previously scheduled 
for update value.

This patch series is against 'net' tree.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
