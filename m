From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] drivers/net/usb/qcusbnet: Checkpatch cleanups
Date: Fri, 01 Oct 2010 06:41:59 -0700
Message-ID: <1285940519.752.10.camel@Joe-Laptop>
References: <20100928171026.GB6083@google.com>
	 <cover.1285727642.git.joe@perches.com>
	 <0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
	 <4CA5E185.3090902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elly Jones <ellyjones@google.com>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, mjg59@srcf.ucam.org,
	jglasgow@google.com, msb@google.com, olofj@google.com
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2607 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab0JANmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 09:42:03 -0400
In-Reply-To: <4CA5E185.3090902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-01 at 16:26 +0300, Paulius Zaleckas wrote:
> On 09/29/2010 05:39 AM, Joe Perches wrote:
> > Whitespace and removal of KERNEL_VERSION tests
> > Neaten DBG macro
> 
> Why not use dev_dbg istead of this ugly DBG macro?

Currently, like a lot of other macros
in the tree, it uses a runtime flag to
control output.

dev_dbg doesn't have that capability.


