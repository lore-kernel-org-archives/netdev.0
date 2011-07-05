From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 5/6] r8169: fix wake on lan setting for 8111E
Date: Tue, 5 Jul 2011 20:55:52 +0200
Message-ID: <20110705185552.GE5105@electric-eye.fr.zoreil.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com> <1309859095-32031-5-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309859095-32031-5-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Only 8111E needs enable RxConfig bit 0 ~ 3 when suspending or
> shutdowning when supporting wake on lan.

Nit: if it only applies to the non-VL 8111E, it could make sense to apply
it after the 8168E-VL support patch and outline this fact in the comment.

Your call.

-- 
Ueimor
