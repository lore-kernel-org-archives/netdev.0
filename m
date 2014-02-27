From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2] openvswitch: Disable bottom half when grabbing stats
 lock in userspace context
Date: Thu, 27 Feb 2014 15:04:56 -0800
Message-ID: <CALnjE+pwjMCDUPP8+DsAbamNxk8nVFKqTa3yC8sZNYFqeFGjHQ@mail.gmail.com>
References: <1393539059-21727-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:38840 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751573AbaB0XE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:04:57 -0500
Received: by mail-vc0-f175.google.com with SMTP id ij19so3211014vcb.6
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 15:04:56 -0800 (PST)
In-Reply-To: <1393539059-21727-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 2:10 PM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> The megaflow feature introduced per-CPU stats, and the new code did some
> refactoring as well [1]. However the new functions doesn't disable bottom halves
> when locking the stat, and as they can be called from userspace context, they
> can be interrupted by netif_receive_skb.
>
> [1] e298e50570: openvswitch: Per cpu flow stats.
>
This bug is fixed in openvswitch repo by commit "datapath: Fix
deadlock during stats update."


Thanks.
