From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] carl9170: Fix mismatch in carl9170_op_set_key mutex lock-unlock
Date: Tue, 23 Aug 2011 23:56:22 +0200
Message-ID: <201108232356.22472.chunkeey@googlemail.com>
References: <1314132272-7357-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51943 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730Ab1HWV4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 17:56:37 -0400
In-Reply-To: <1314132272-7357-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, August 23, 2011 10:44:32 PM Alexey Khoroshilov wrote:
> If is_main_vif(ar, vif) reports that we have to fall back
> to software encryption, we goto err_softw; before locking ar->mutex.
> As a result, we have unprotected call to carl9170_set_operating_mode
> and unmatched mutex_unlock.
> 
> The patch fix the issue by adding mutex_lock before goto.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Cc: <stable@kernel.org>
Acked-By: Christian Lamparter <chunkeey@googlemail.com>
