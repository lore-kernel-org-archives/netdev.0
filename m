From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] Fix broken RBTX4927 support in ne.c
Date: Wed, 28 Feb 2007 18:57:28 +0000
Message-ID: <20070228185728.GA16562@linux-mips.org>
References: <20070301.012223.129448787.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, sshtylyov@ru.mvista.com,
	netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:37611 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932327AbXB1S5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 13:57:39 -0500
Received: from localhost.localdomain ([127.0.0.1]:48049 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S28573698AbXB1S5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 18:57:37 +0000
Content-Disposition: inline
In-Reply-To: <20070301.012223.129448787.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 01:22:23AM +0900, Atsushi Nemoto wrote:

> There are some ifdefs for RBTX4927, but need some more bits.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Longer term I think NE2000 will need to support platform_devices.  It's
been used too widely in too creative ways and we don't want all the
clutter to deal with that in ne.c.

  Ralf
