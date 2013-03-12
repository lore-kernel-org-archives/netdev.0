From: David Miller <davem@redhat.com>
Subject: Re: [PATCHv2] caif: remove caif_shm
Date: Tue, 12 Mar 2013 07:47:00 -0400 (EDT)
Message-ID: <20130312.074700.1041842049586056719.davem@redhat.com>
References: <1363007583-16513-1-git-send-email-erwan.yvin@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linus.walleij@linaro.org,
	sjur.brandeland@stericsson.com
To: erwan.yvin@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932497Ab3CLLqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 07:46:53 -0400
In-Reply-To: <1363007583-16513-1-git-send-email-erwan.yvin@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erwan Yvin <erwan.yvin@stericsson.com>
Date: Mon, 11 Mar 2013 14:13:03 +0100

> caif_shm is an old implementation
> caif_shm will be replaced by caif_virtio
> 
> Signed-off-by: Erwan Yvin <erwan.yvin@stericsson.com>
> Acked-by: Sjur Brendeland <sjur.brandeland@stericsson.com>

You can't just rip things out of the kernel that people might
still be using.

Even worse is doing so without providing an alternative first.
