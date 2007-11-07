From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'fixes-davem' branch of wireless-2.6
Date: Wed, 7 Nov 2007 15:38:14 +0100
Message-ID: <200711071538.14826.mb@bu3sch.de>
References: <20071107001314.GH4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44688
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758621AbXKGOjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:39:01 -0500
In-Reply-To: <20071107001314.GH4440@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 November 2007 01:13:14 John W. Linville wrote:
> "ssb: Fix initcall ordering" changes a subsys_initcall to an
> fs_initcall.  This seems like a bit of a hack, but it fixes a real
> problem and I'm not sure what cleaner solution is either reasonable
> or available.  The comment in the patch explains the reasoning for this
> somewhat unique situation.

Well, ssb is not the only subsystem with this special requirement.
Grep for fs_initcall. In my opinion we need another initcall to fix
this issue. I think we need a post_subsys_initcall().
But that really is another issue that we can't decide in netdev.
For now, this fix is harmless and fixes the bug.

-- 
Greetings Michael.
