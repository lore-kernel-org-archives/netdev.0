From: Tino Reichardt <list-linux-netdev@mcmilk.de>
Subject: Re: [PATCHSET net-next v3 00/07] Support for byte queue limits on
 various drivers
Date: Sun, 20 Oct 2013 22:19:08 +0200
Message-ID: <20131020201908.GC24935@mcmilk.de>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:53467 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab3JTUTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 16:19:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by lotte.svc-box.de (Postfix) with ESMTP id D233F1480BA5
	for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 22:19:09 +0200 (CEST)
Received: from lotte.svc-box.de ([127.0.0.1])
	by localhost (lotte.svc-box.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id o7-FsnVhDBUa for <netdev@vger.kernel.org>;
	Sun, 20 Oct 2013 22:19:08 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tino Reichardt <milky-kernel@mcmilk.de> wrote:
> Hello again,
> 
> this patchset is intended for net-next/linux-3.13.
> 
> It adds support for byte queue limits on various network drivers.
> 
> Since not all of them are fully tested by now, I added an bql_disable
> module parameter, which can be used to disable the BQL code.
> 
> "if (likely(bql_disable == false))" was replaced by
> "if (unlikely(bql_disable))" ...


Please ignore Patchset v3... "unlikely(bql_disable)" is of cause not
correct :(


Please use "[PATCHSET net-next v3 00/07]" instead.

Sorry for all the noise here ;)

-- 
Best regards, TR
