From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Sat, 16 Apr 2016 17:31:50 +0300
Message-ID: <57124CD6.4040503@cogentembedded.com>
References: <5711AA52.6010400@brocade.com> <5711ADD1.2030904@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36751 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbcDPObx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 10:31:53 -0400
Received: by mail-lf0-f47.google.com with SMTP id g184so174354321lfb.3
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 07:31:52 -0700 (PDT)
In-Reply-To: <5711ADD1.2030904@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/16/2016 6:13 AM, Mike Manning wrote:

> f1705ec197e7 added the option to retain user configured addresses on an
> admin down. A comment to one of the later revisions suggested using the
> IFA_F_PERMANENT flag rather than adding a user_managed boolean to the
> ifaddr struct. A side effect of this change is that link local and
> loopback addresses are also retained which is not part of the objective
> of f1705ec197e7. Add check so that these addresses are not fixed up,
> given that a related fix 70af921db6f8 ensures that they are not kept in

    scripts/checkpatch.pl now enforces commit citing certain style: <12-digit 
SHA1> ("<comit summary>").

> the first place, otherwise this incorrect fixup triggers a crash in fib6.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
[...]

MBR, Sergei
