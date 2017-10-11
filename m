From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] ss: print MD5 signature keys configured on
 TCP sockets
Date: Wed, 11 Oct 2017 11:06:54 -0700
Message-ID: <20171011110654.260f9b8c@xeon-e3>
References: <20171006234820.27567-1-colona@arista.com>
        <20171006234820.27567-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:49329 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbdJKSHB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:07:01 -0400
Received: by mail-pg0-f54.google.com with SMTP id v13so1419158pgq.6
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:07:01 -0700 (PDT)
In-Reply-To: <20171006234820.27567-2-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 Oct 2017 16:48:20 -0700
Ivan Delalande <colona@arista.com> wrote:

> These keys are reported by kernel 4.14 and later under the
> INET_DIAG_MD5SIG attribute, when INET_DIAG_INFO is requested (ss -i)
> and we have CAP_NET_ADMIN. The additional output looks like:
> 
> 	md5keys:fe80::/64=signing_key,10.1.2.0/24=foobar,::1/128=Test
> 
> Signed-off-by: Ivan Delalande <colona@arista.com>

Sure makes sense applied.
