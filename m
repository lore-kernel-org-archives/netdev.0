From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Mon, 8 Sep 2008 19:28:35 +0400
Message-ID: <20080908152835.GA16834@2ka.mipt.ru>
References: <20080905141911.GA16586@2ka.mipt.ru> <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com> <20080905145902.GA12762@2ka.mipt.ru> <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com> <20080905153811.GA3596@2ka.mipt.ru> <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com> <20080905163446.GB10078@2ka.mipt.ru> <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com> <20080908112629.GA26488@2ka.mipt.ru> <7e0dd21a0809080601lc250197wde17733522d03125@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:45881 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706AbYIHP3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 11:29:06 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809080601lc250197wde17733522d03125@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Mon, Sep 08, 2008 at 03:01:04PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> > Are you sure that it is udp_push_pending_frames() and not some splice
> > waiting?
> >
> No, I'm not sure.
> Are there any queue or allocator limits that can slow the bitrate
> through this function?

No.

> I mean something that will need end of transfer to start a new one.

No, there shuld not be any such code path.

What is CPU usage on sender when it sends data via UDP sendfile()?

-- 
	Evgeniy Polyakov
