From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 17:11:12 +0200
Message-ID: <1339168272.6001.116.camel@edumazet-glaptop>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	 <20120607.230216.2014005732863772019.davem@davemloft.net>
	 <1339135881.6001.25.camel@edumazet-glaptop>
	 <20120607.231501.463746858434969001.davem@davemloft.net>
	 <1339138040.6001.39.camel@edumazet-glaptop>
	 <1339140238.6001.42.camel@edumazet-glaptop>
	 <CA+mtBx9xpy6Ly=3kiBc+sdHqFfsO5KRK8O=VAXTb3rofAgm2ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43041 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036Ab2FHPLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 11:11:16 -0400
Received: by eaak11 with SMTP id k11so1183709eaa.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 08:11:14 -0700 (PDT)
In-Reply-To: <CA+mtBx9xpy6Ly=3kiBc+sdHqFfsO5KRK8O=VAXTb3rofAgm2ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 08:04 -0700, Tom Herbert wrote:

> Maybe the fundamental issue is that the queue mappings only allow for
> one level of multi queue device.  It might be better if bonding didn't
> have one and dev_pick_tx did the right thin (use xps on bonding
> maybe).

bonding misuses multiqueue infrastructure to divert frames on selected
slaves, or maybe I am wrong.
