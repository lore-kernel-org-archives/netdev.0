From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: Fix vs->vni_list locking.
Date: Wed, 10 Jul 2013 15:58:40 -0700
Message-ID: <20130710155840.73e8da09@nehalam.linuxnetplumber.net>
References: <1373493884-7915-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:53928 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab3GJW6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 18:58:46 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj3so7223716pad.0
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 15:58:46 -0700 (PDT)
In-Reply-To: <1373493884-7915-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Jul 2013 15:04:44 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Use rtnl lock to protect vs->vni_list updates.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---

I don't think this is necessary. I intentionally changed the
locking when socket management was moved to a work queue.
The vxlan_net socket lock is held there already, and finer grain.
