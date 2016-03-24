From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 0/2] setting flow label support
Date: Thu, 24 Mar 2016 16:49:54 +0100
Message-ID: <cover.1458833866.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43845 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbcCXPuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 11:50:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On top of Jesse's csum patches for vxlan, geneve:

  - http://patchwork.ozlabs.org/patch/599746/
  - http://patchwork.ozlabs.org/patch/599747/

Thanks!

Daniel Borkmann (2):
  vxlan: add support to set flow label
  geneve: add support to set flow label

 ip/ip_common.h        |  4 ++++
 ip/iplink_geneve.c    | 29 ++++++++++++++++++++++++-----
 ip/iplink_vxlan.c     | 29 ++++++++++++++++++++++++-----
 man/man8/ip-link.8.in | 12 ++++++++++++
 4 files changed, 64 insertions(+), 10 deletions(-)

-- 
1.9.3
