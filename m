From: Saku Ytti <saku@ytti.fi>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 10:54:04 +0200
Message-ID: <20121128085404.GB26010@pob.ytti.fi>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
 <50B4F2DA.8020206@hp.com>
 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
 <20121127.210611.1127622873924794001.davem@davemloft.net>
 <20121128072611.GA26010@pob.ytti.fi>
 <CAGK4HS_GVZqoGVjd87N6skM-SBWyPtY-AhiR9FDcR8ty5x6Xbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:52295 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876Ab2K1IyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 03:54:11 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so7495243lag.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 00:54:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAGK4HS_GVZqoGVjd87N6skM-SBWyPtY-AhiR9FDcR8ty5x6Xbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (2012-11-28 00:35 -0800), Vijay Subramanian wrote:

> Also note that reordering is tracked on the sender side using the per
> flow variable tp->reordering . This measures the amount of reordering
> on the connection so that
> fast retransmit and other loss recovery mechanisms are not entered
> prematurely. Doesn't this behavior at the  sender already provide the
> behavior you seek?

Sorry I don't seem to understand what you mean. Do you mind explaining how
the sender can help to restore performance on reordering network?

-- 
  ++ytti
