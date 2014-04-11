From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Fri, 11 Apr 2014 14:04:46 -0700
Message-ID: <20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:53195 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbaDKVEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 17:04:49 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so5680619pdj.26
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 14:04:49 -0700 (PDT)
In-Reply-To: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Apr 2014 10:17:06 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> It is useful to allow user to specify to terminate u32 filter matching
> when there is no action. Currently we only terminate it when there is
> an action attached.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  tc/f_u32.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)

Iproute2 commands are supposed to be invertible.
If you take something as input, it should be displayed on output.
