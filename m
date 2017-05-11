From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] samples/bpf: run cleanup routines when receiving
 SIGTERM
Date: Fri, 12 May 2017 01:34:56 +0200
Message-ID: <5914F520.3010709@iogearbox.net>
References: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shahid.habib@broadcom.com
To: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36399 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932267AbdEKXfI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 19:35:08 -0400
In-Reply-To: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2017 09:52 PM, Andy Gospodarek wrote:
> Shahid Habib noticed that when xdp1 was killed from a different console the xdp
> program was not cleaned-up properly in the kernel and it continued to forward
> traffic.
>
> Most of the applications in samples/bpf cleanup properly, but only when getting
> SIGINT.  Since kill defaults to using SIGTERM, add support to cleanup when the
> application receives either SIGINT or SIGTERM.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Reported-by: Shahid Habib <shahid.habib@broadcom.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
