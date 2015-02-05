From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH bluetooth-next v3] ieee802154: fix netns settings
Date: Thu, 5 Feb 2015 18:31:14 +0100
Message-ID: <20150205173111.GA14300@omega>
References: <1DEA1346-A348-434E-90F3-80E9EDC7E181@holtmann.org>
 <1423156890-13382-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: marcel@holtmann.org, netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:48526 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbbBERbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:31:22 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so8998509wes.7
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 09:31:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423156890-13382-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

On Thu, Feb 05, 2015 at 06:21:30PM +0100, Nicolas Dichtel wrote:
> 6LoWPAN currently doesn't supports x-netns and works only in init_net.
> 
> With this patch, we ensure that:
>  - the wpan interface cannot be moved to another netns;
>  - the 6lowpan interface cannot be moved to another netns;
>  - the wpan interface is in the same netns than the 6lowpan interface;
>  - the 6lowpan interface is in init_net.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Acked-by: Alexander Aring <alex.aring@gmail.com>

thanks for resend this patch and added my ack, thanks.

- Alex
