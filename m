From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] ila: Fix tailroom allocation of lwtstate
Date: Thu, 20 Oct 2016 17:52:33 +0200
Message-ID: <20161020155233.GA3470@pox.localdomain>
References: <d7e2292a2be9d142a05b7c528746820bac358065.1476911506.git.tgraf@suug.ch>
 <20161020.112019.468220952101459876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34216 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964884AbcJTPwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:52:35 -0400
Received: by mail-qk0-f169.google.com with SMTP id f128so97713701qkb.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 08:52:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161020.112019.468220952101459876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/16 at 11:20am, David Miller wrote:
> This patch only applies to net-next, so I've applied it there.
> 
> Please explain how I should handle 'net' and -stable.

The presence of ila_params_lwtunnel() in 'net' lead me to believe that
'net' is affected as well. It is not. Applying to 'net-next' only is
fine.
