From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH 1/2] ucc_geth: Do not bring the whole IF down when TX
 failure.
Date: Fri, 12 Nov 2010 17:05:15 +0300
Message-ID: <20101112140515.GA28223@oksana.dev.rtsoft.ru>
References: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40843 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094Ab0KLOFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 09:05:23 -0500
Received: by eye27 with SMTP id 27so1825742eye.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 06:05:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 12, 2010 at 02:55:08PM +0100, Joakim Tjernlund wrote:
> ucc_geth_close lacks a cancel_work_sync(&ugeth->timeout_work)
> to stop any outstanding processing of TX fail. However, one
> can not call cancel_work_sync without fixing the timeout function
> otherwise it will deadlock. This patch brings ucc_geth in line with
> gianfar:
> 
> Don't bring the interface down and up, just reinit controller HW
> and PHY.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Looks sane, thanks!

Reviewed-by: Anton Vorontsov <cbouatmailru@gmail.com>
