From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 08/10] tty_io: export tty_class
Date: Mon, 1 Jun 2009 16:34:18 +0100
Message-ID: <20090601163418.465be751@lxorguk.ukuu.org.uk>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-9-git-send-email-dbaryshkov@gmail.com>
	<20090601160721.7b262469@lxorguk.ukuu.org.uk>
	<bc64b4640906010810l8ace77byfbd650b549f9b5c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:60417 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752363AbZFAPdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 11:33:10 -0400
In-Reply-To: <bc64b4640906010810l8ace77byfbd650b549f9b5c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I used class_find_device finding the device with matching minor. Will it be
> acceptable, if I just move this code into tty_* file and export it as
> to modules?

Yes - create a proper tty helper function for doing the job and document
what it does. That way if the tty layer is changed it is obvious that
this code also needs considering.

Alan
