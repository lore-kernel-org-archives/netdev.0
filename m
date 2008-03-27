From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: O(n^2) or worse ?   cat /proc/net/tcp
Date: Thu, 27 Mar 2008 12:51:23 +0200
Message-ID: <20080327105123.GS3700@mea-ext.zmailer.org>
References: <20080323224307.GL3700@mea-ext.zmailer.org> <87lk487ol7.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:41945 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755263AbYC0Kv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 06:51:26 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3540384AbYC0KvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 12:51:23 +0200
Content-Disposition: inline
In-Reply-To: <87lk487ol7.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2008 at 05:06:28AM +0100, Andi Kleen wrote:
> Matti Aarnio <matti.aarnio@zmailer.org> writes:
> > 
> > I did observe odd slowness at first with  "lsof -p .."  program, 
> 
> You could oprofile it.

Ah, I forgot to start learning of oprofile..

> > then at
> > "netstat -na".  Same slowdown happens with:  cat /proc/net/tcp
> > (that 'cat' took 25 seconds...)
> 
> /proc/net/tcp should be only O(n^2) if the application does a lot of 
> open()/seek()/read()/close() for very small chunks, but at least netstat
> doesn't do that. Not sure about lsof though.

Or  cat  -- which definitely does not seek around..

> -Andi

  /Matti Aarnio
