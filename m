From: Saku Ytti <saku@ytti.fi>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 20:44:38 +0200
Message-ID: <20121128184438.GA26814@pob.ytti.fi>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
 <50B4F2DA.8020206@hp.com>
 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
 <20121127.210611.1127622873924794001.davem@davemloft.net>
 <20121128072611.GA26010@pob.ytti.fi>
 <CAGK4HS_GVZqoGVjd87N6skM-SBWyPtY-AhiR9FDcR8ty5x6Xbg@mail.gmail.com>
 <20121128085404.GB26010@pob.ytti.fi>
 <50B656CC.1040001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:35380 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712Ab2K1Sop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:44:45 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so7985001lag.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 10:44:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50B656CC.1040001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (2012-11-28 10:24 -0800), Rick Jones wrote:

> By increasing net.ipv4.tcp_reordering you make the sending TCP less
> "sensitive" to duplicate ACKs and so less sensitive to reordering
> detected by the receiver.  The receiver is generating as many
> (duplicate) ACKs as before, it is just that the sender is ignoring
> them a bit more.

Thanks, I didn't know this.

-- 
  ++ytti
