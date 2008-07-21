From: Olaf Hering <olaf@aepfle.de>
Subject: include/linux/ipv6.h, struct ipv6_devconf  leaks to userspace
Date: Mon, 21 Jul 2008 14:34:30 +0200
Message-ID: <20080721123430.GA28599@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42178 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbYGUMec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 08:34:32 -0400
Received: from mail01.m-online.net (mail.m-online.net [192.168.3.149])
	by mail-out.m-online.net (Postfix) with ESMTP id 0A7F943B6CB
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 14:34:31 +0200 (CEST)
Received: from ibook.aepfle.de (DSL01.83.171.152.220.ip-pool.NEFkom.net [83.171.152.220])
	by mail.mnet-online.de (Postfix) with ESMTP id 0186E9088E
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 14:34:30 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Found by make O="$header_dir" headers_install_all in 2.6.26:

struct ipv6_devconf contains conditional members, guarded by CONFIG_*.

Please move the struct into #ifdef __KERNEL__


Olaf
