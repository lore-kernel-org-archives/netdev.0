From: David Rientjes <rientjes@google.com>
Subject: Re: Latest 3.6.6 are not compiling due tg3 network driver,
 hwmon_device_unregister
Date: Wed, 14 Nov 2012 19:30:30 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com>
References: <8b566c4a9ee622737212dc17291ee238@visp.net.lb> <50A4606D.4020402@broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46957 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992469Ab2KODad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:30:33 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so848421pbc.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 19:30:32 -0800 (PST)
In-Reply-To: <50A4606D.4020402@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Nov 2012, Nithin Nayak Sujir wrote:

> This was fixed by
> 
> commit de0a41484c47d783dd4d442914815076aa2caac2
> Author: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date:   Mon Oct 1 11:43:49 2012 -0400
> 
>     tg3: unconditionally select HWMON support when tg3 is enabled.
> 

Would you mind submitting this for stable by following the procedure 
described in Documentation/stable_kernel_rules.txt?
