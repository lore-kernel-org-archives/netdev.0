From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [PATCH net] be2net: perform temperature query in adapter
 regardless of its interface state
Date: Wed, 27 Jul 2016 09:35:46 +0530
Message-ID: <ffb741d4f1204695951ee7fa4f4138df@mail.gmail.com>
References: <1469565582-5984-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	Ajit Kumar Khaparde <ajit.khaparde@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:33321 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbcG0EFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 00:05:48 -0400
Received: by mail-yw0-f171.google.com with SMTP id r9so46546523ywg.0
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 21:05:48 -0700 (PDT)
In-Reply-To: <1469565582-5984-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Guilherme G. Piccoli [mailto:gpiccoli@linux.vnet.ibm.com]
>
> The be2net driver performs fw temperature queries on be_worker()
routine, which is executed each second for
> each be_adapter. There is a frequency threshold to avoid fw query to
happens at each call to be_worker();
> instead, currently a fw query occurs once in 64 runs of the procedure.
>
> Nevertheless, this fw temperature query is invoked only for adapters
which interface is up, so we can see I/O
> errors on read of hwmon counters from userspace (from tools like
lm-sensors) in case we have adapters'
> functions which interface is down.
>
> This patch moves the fw query code to be invoked even if interface is
down.
> No functional changes were introduced.
>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Acked-by: Sathya Perla <sathya.perla@broadcom.com>
