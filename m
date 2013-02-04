From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: display the value of IFLA_PROMISCUITY
Date: Mon, 4 Feb 2013 09:04:19 -0800
Message-ID: <20130204090419.2e351ac5@nehalam.linuxnetplumber.net>
References: <CB4696DA7737D0409230B481D0363B1414F0E60461@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32847 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab3BDREd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 12:04:33 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so2532752pad.10
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 09:04:33 -0800 (PST)
In-Reply-To: <CB4696DA7737D0409230B481D0363B1414F0E60461@HQ1-EXCH03.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jan 2013 06:47:56 -0800
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This is usefull to know the 'real' status of an interface (the flag IFF_PROMISC
> is exported by the kernel only when the user set it explicitly, for example it
> will not be exported when a tcpdump is running).
> 
> Note that I add a space after qlen (instead of before promiscuity) to be
> coherent with the rest of the code.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  ip/ipaddress.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

The idea is good, but I can't accept in the current form.
The problem with this is that it violates the unwritten assumption that the output
of ip command should be the arguments used to setup that interface. There were even
some VPN's that depended on that.
