From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v3] [1/10] pasemi_mac: A couple of minor bugfixes.
Date: Tue, 08 May 2007 01:02:09 -0400
Message-ID: <46400451.3000706@pobox.com>
References: <20070428203624.GA4331@lixom.net> <20070428203640.GB4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54189 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967841AbXEHFCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:02:12 -0400
In-Reply-To: <20070428203640.GB4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Bugfixes:
> 
> * Move the wake_queue logic from tx_intr to clean_tx
> * Always do wake_queue even if queue wasn't full before clean since
>   it's safe to do
> * Fix polarity in checks in pasemi_mac_close
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied


