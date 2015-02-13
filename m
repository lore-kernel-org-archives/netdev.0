From: Cong Wang <cwang@twopensource.com>
Subject: Re: vnet problem (bug? feature?)
Date: Fri, 13 Feb 2015 15:48:14 -0800
Message-ID: <CAHA+R7NUojPsLY9LOC94S0uussbwKsGRdcbazNmGGLbXvxCk-A@mail.gmail.com>
References: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Toerless Eckert <tte@cs.fau.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:46520 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbbBMXsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 18:48:15 -0500
Received: by iecvy18 with SMTP id vy18so23143458iec.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 15:48:15 -0800 (PST)
In-Reply-To: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2015 at 3:41 AM, Toerless Eckert <tte@cs.fau.de> wrote:
> Hope this is the right mailing list, if not, then which one ? (thanks)

Yes it is.

>
> - Created vnet pair
> - NOT putting them into different namespaces.
> - Unicast across them works fine.
> - When sending IP multicsast into one end, i can not receive it on the other side
>   (with normal socket API applications).
>

Hmm, what does your routing table look like?

They are in the same namespace, so in the same stack, so their IP addresses
belong to the same stack.
