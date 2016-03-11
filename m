From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Fri, 11 Mar 2016 14:43:19 +0000
Message-ID: <D841AFE4-6955-4013-BA3A-B10F6FAB6539@gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com> <CALx6S36_ii9hOj_Jn+xKxjoZQfbb-TfdQysH-N+Zic-bMHnHPg@mail.gmail.com> <69BFB2EA-BADE-420C-93E5-1320D53EB2C0@gmail.com> <CALx6S35UMTif0pFMKLV4Ks8hVkb9L-=571pURbGkXEux4VJfyA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38346 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbcCKOn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 09:43:28 -0500
Received: by mail-wm0-f45.google.com with SMTP id l68so20399696wml.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 06:43:27 -0800 (PST)
In-Reply-To: <CALx6S35UMTif0pFMKLV4Ks8hVkb9L-=571pURbGkXEux4VJfyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 7 Mar 2016, at 17:49, Tom Herbert <tom@herbertland.com> wrote:
> 
>> That said, do you believe it could be an option to maybe have both these
>> options? I think that the ability to run BPF in the listening path is
>> really interesting, but it's probably an overkill for the bind-to-subnet
>> use case.
>> 
> 
> Maybe. It will be quite common server configuration with IPv6 to
> assign each server its own /64 prefix(es). From that POV I suppose
> there is some value in having SO_BINDTOSUBNET.

Good, in this case I will submit again this RFC when the net-next window
will open for the 4.6 release, so that we can gather more comments and
decide what to do.

Thank you,
  Gilberto
