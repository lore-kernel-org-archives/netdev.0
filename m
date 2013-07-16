From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: Mon, 15 Jul 2013 18:27:17 -0700
Message-ID: <1373938037.10804.82.camel@edumazet-glaptop>
References: <20130712180116.21176.qmail@science.horizon.com>
	 <1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
	 <CAP6odjjyXqhMBAY3L1p7w9UPU2VH04MsyaWG6wb1YB_Pe43Dyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	George Spelvin <linux@horizon.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:45283 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606Ab3GPB1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 21:27:20 -0400
Received: by mail-ob0-f179.google.com with SMTP id xk17so114616obc.24
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 18:27:19 -0700 (PDT)
In-Reply-To: <CAP6odjjyXqhMBAY3L1p7w9UPU2VH04MsyaWG6wb1YB_Pe43Dyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-15 at 18:17 -0700, Grant Grundler wrote:

> Even for tulip driver?  Sorry, I just can't imagine anyone taking
> enough interest in tulip driver to implement that.  I'm not even sure
> it would be possible.
> 

I would not care. When I reviewed this patch, I was aware of this
problem (as this is the most common error done in BQL patches), and
decided patch was fine, because lock was held.
