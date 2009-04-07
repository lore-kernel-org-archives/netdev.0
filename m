From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bas_gigaset: use tasklet_hi_schedule for timing
 critical tasklets
Date: Mon, 06 Apr 2009 17:43:34 -0700 (PDT)
Message-ID: <20090406.174334.154575716.davem@davemloft.net>
References: <20090404-patch-00.tilman@imap.cc>
	<20090404-patch-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, hjlipp@web.de
To: tilman@imap.cc
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759036AbZDGAn7@vger.kernel.org>
In-Reply-To: <20090404-patch-01.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun,  5 Apr 2009 18:39:33 +0200 (CEST)

> The tasklets for isochronous data transfer need to run within 8 msec
> to avoid over/underruns, so schedule them with high priority to fix
> reported issues with occasional over/underruns.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
