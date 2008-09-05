From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 20:34:46 +0400
Message-ID: <20080905163446.GB10078@2ka.mipt.ru>
References: <20080905131618.GB12246@2ka.mipt.ru> <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com> <20080905133748.GA28656@2ka.mipt.ru> <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com> <20080905141911.GA16586@2ka.mipt.ru> <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com> <20080905145902.GA12762@2ka.mipt.ru> <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com> <20080905153811.GA3596@2ka.mipt.ru> <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:46230 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbYIEQfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 12:35:18 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Fri, Sep 05, 2008 at 06:01:46PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> I'm leaving office right now.
> I'll come back toward you regarding this topic on Monday.

No problem.

> Ok, I see. I just need to check if UDP is fine for my application or
> if i need to do my own L3/L4.

This may be a bad sign. Or extremely needed step like in satellite links
with its huge rtts. Likely in case of ethernet usage tcp/udp over IP is
the way to go.

-- 
	Evgeniy Polyakov
