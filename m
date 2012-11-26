From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipmr: limit MRT_TABLE identifiers
Date: Sun, 25 Nov 2012 18:19:32 -0800
Message-ID: <1353896372.30446.866.camel@edumazet-glaptop>
References: <50AC9CF6.2020501@asianux.com>
	 <1353872669.30446.863.camel@edumazet-glaptop>
	 <50B2C470.5090802@asianux.com>  <50B2C72F.9000100@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:64529 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab2KZCTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 21:19:36 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so7684729iay.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 18:19:36 -0800 (PST)
In-Reply-To: <50B2C72F.9000100@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 09:34 +0800, Chen Gang wrote:

>     if "pimre%u" (or another format), will not hurt the functional features, I suggest to use it
>       since, we need try our best to not touch the OS API. 
>       ("pimreg%u" seems an internal format, not OS API Level)

Have you taken a look at user code base before suggesting such a
change ?

My patch is the safest change: Just make sure machine doesnt crash if
user ask stupid things.

No possible regression.
