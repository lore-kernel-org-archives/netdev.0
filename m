From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/6] netns: returns always an id in
 __peernet2id()
Date: Wed, 6 May 2015 13:19:00 +0200
Message-ID: <20150506111900.GA25248@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430906288-5108-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34233 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbEFLTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 07:19:03 -0400
Received: by wicmx19 with SMTP id mx19so122615925wic.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 04:19:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430906288-5108-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
> All callers of this function expect a nsid, not an error.
> Thus, returns NETNSA_NSID_NOT_ASSIGNED in case of error.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I thought it was a bugfix based on the commit message. It's
a nice cleanup though.

Acked-by: Thomas Graf <tgraf@suug.ch>
