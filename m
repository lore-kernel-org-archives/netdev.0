From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: XTP for 2.6.25
Date: Fri, 25 Apr 2008 11:23:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804251115470.2363@wrl-59.cs.helsinki.fi>
References: <18b669d80804240314t7b2f6e4cpc9a9f2690c6d21b4@mail.gmail.com>
 <873apbijb9.fsf@basil.nowhere.org>  <18b669d80804240606n47854939x94278f8d974034c1@mail.gmail.com>
 <18b669d80804250059m793f3f56xc4fdb8bad949fa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Shigeo N <shigeonx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37246 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754383AbYDYIYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 04:24:01 -0400
In-Reply-To: <18b669d80804250059m793f3f56xc4fdb8bad949fa3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Apr 2008, Shigeo N wrote:

> case2) random delay
> 
>  In this case, add a fixed amount of delay + 10% random delay by
> command, "tc change dev eth0 root netem delay 100ms 10ms 25%".
> 
>  Here is the result.
> 
>     fixed delay    UDP/TCP/XTP throghput
>   ---------------------------------------
>       10ms         88/80/92 Mbps
>       30ms         88/51/91 Mbps
>       50ms         88/41/89 Mbps
>       70ms         88/28/80 Mbps
>      100ms         88/19/66 Mbps
> 
>  TCP's perfomance looks very poor when delay is long and variable.

Where these results with 2.6.25 as well? ...John Heffner just couple of 
days ago fixed reordering related problem in TCP (in case that netem 
parametrization causes reordering), the fix is not even in 2.6.24.y, I 
think...

-- 
 i.
