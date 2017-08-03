From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] netns: make /var/run/netns bind-mount
 recursive
Date: Thu, 3 Aug 2017 16:04:21 -0700
Message-ID: <20170803160421.58eb0a4a@xeon-e3>
References: <20170801154609.29895-1-casey.callendrello@coreos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Casey Callendrello <casey.callendrello@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33334 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdHCXEX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:04:23 -0400
Received: by mail-pf0-f181.google.com with SMTP id d67so584346pfc.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:04:23 -0700 (PDT)
In-Reply-To: <20170801154609.29895-1-casey.callendrello@coreos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Aug 2017 17:46:09 +0200
Casey Callendrello <casey.callendrello@coreos.com> wrote:

> When ip netns {add|delete} is first run, it bind-mounts /var/run/netns
> on top of itself, then marks it as shared. However, if there are already
> bind-mounts in the directory from other tools, these would not be
> propagated. Fix this by recursively bind-mounting.
> 
> Signed-off-by: Casey Callendrello <casey.callendrello@coreos.com>
> ---
>  ip/ipnetns.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

Looks good, but I want a review by Eric to make sure this doesn't break other things.
