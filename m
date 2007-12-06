From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice
	regression?
Date: Thu, 6 Dec 2007 02:13:00 +0100
Message-ID: <20071206011300.GA11792@electric-eye.fr.zoreil.com>
References: <pan.2007.11.29.23.42.52.661624@wizards.de> <474FC4D9.3020506@cosmosbay.com> <pan.2007.11.30.09.20.24.737500@wizards.de> <475055EE.9060105@hp.com> <pan.2007.12.02.16.00.03.568000@wizards.de> <pan.2007.12.02.20.49.42.675000@wizards.de> <20071205225429.GA10186@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Holger Hoffstaette <holger@wizards.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34619 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751629AbXLFBSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 20:18:15 -0500
Content-Disposition: inline
In-Reply-To: <20071205225429.GA10186@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> Holger Hoffstaette <holger@wizards.de> :
> [...]
> > Should I file this in bugzilla?
> 
> Yes.

5326 5585327 5585328 5585329 5585330 5585331 5585332 5585333 5585334 5585335 558
5336 5585337 5585338 5585339 5585340 5585341 5585342 5585343 5589440 5589441 558
                                                     ^^^^^^^ ^^^^^^^
9442 5589443 5589444 5589445 5589446 5589447 5589448 5589449 5589450 5589451 558
9452 5589453 5589454 5589455 5589456 5589457 5589458 5589459 5589460 5589461 558

It misses 8*4096 bytes.

8443 9068442 9068441 9068440 9068439 9068438 9068437 9068436 9068435 9068434 906
8433 9068432 9068431 9068430 9068429 9068428 9068427 9064330 9064329 9064328 906
                                             ^^^^^^^ ^^^^^^^
4327 9064326 9064325 9064324 9064323 9064322 9064321 9064320 9064319 9064318 906

Same thing later.

But the amount of data transmitted is fine.

Could you locate the offsets were the sequence is broken ?

-- 
Ueimor
