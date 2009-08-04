From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]atl1c:Do not call cancel_work_sync from the work itself
Date: Mon, 03 Aug 2009 19:32:33 -0700 (PDT)
Message-ID: <20090803.193233.170901476.davem@davemloft.net>
References: <12493523461127-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755184AbZHDCcZ@vger.kernel.org>
In-Reply-To: <12493523461127-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Tue, 4 Aug 2009 10:19:06 +0800

> Do not call cancel_work_sync from the work itself, for it my cause 
> recursive locking.

Sorry, this won't work.

Your patches, all of them, are corrupted by your email client.  It
turns tab characters into spaces as well as making other textual
modifications to the patch, such that it will not apply.

Please fix this up and resubmit all of your patches when the problem
is corrected.

If you have to, email the patches to yourself and try to apply them
just to make sure.
