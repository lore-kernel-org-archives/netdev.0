From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 4/7] netns: notify new nsid outside
 __peernet2id()
Date: Thu, 7 May 2015 13:47:33 +0200
Message-ID: <20150507114733.GA16619@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-5-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f194.google.com ([209.85.212.194]:33981 "EHLO
	mail-wi0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbEGLrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 07:47:42 -0400
Received: by wivr20 with SMTP id r20so5345155wiv.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 04:47:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430989373-4515-5-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/15 at 11:02am, Nicolas Dichtel wrote:
> There is no functional change with this patch. It will ease the refactoring
> of the locking system that protects nsids and the support of the netlink
> socket option NETLINK_LISTEN_ALL_NSID.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks much cleaner this way, thanks.

Acked-by: Thomas Graf <tgraf@suug.ch>
