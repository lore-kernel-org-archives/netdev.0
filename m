From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] rose_add_loopback_node: propagate -E
Date: Sun, 3 Dec 2006 08:52:10 +0000
Message-ID: <20061203085210.GA12645@linux-mips.org>
References: <20061202213339.GB2714@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:10217 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S936686AbWLCIwp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 03:52:45 -0500
Received: from localhost.localdomain ([127.0.0.1]:33256 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038746AbWLCIwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 08:52:43 +0000
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061202213339.GB2714@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 03, 2006 at 12:33:39AM +0300, Alexey Dobriyan wrote:

> David Binderman's icc logs:
> net/rose/rose_route.c(399): remark #593: variable "err" was set but never used

Which is more of a non-fix because all the callers ignore the return
value ...

  Ralf
