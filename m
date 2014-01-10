From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2] ipv6: move IPV6_TCLASS_SHIFT into ipv6.h
Date: Fri, 10 Jan 2014 10:33:58 -0800
Message-ID: <CAHA+R7Ob3Zhv=Oesh1cp53-0Eb-Cp2+dyduidT-KE0X3Tbqdmg@mail.gmail.com>
References: <1389348199-5855-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35225 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbaAJSeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:34:00 -0500
Received: by mail-la0-f48.google.com with SMTP id n7so3459647lam.21
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 10:33:59 -0800 (PST)
In-Reply-To: <1389348199-5855-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 2:03 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> Two places defined IPV6_TCLASS_SHIFT, so we should move it into ipv6.h,
> and use this macro as possible.
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  Sorry, version 1 has bug in fib6_rule_match it should be frist
> mask flowlabel with IPV6_TCLASS_MASK, then call ntohl


Since you are on it, it's better to introduce a helper function
for these 'shift and mask' operation.
