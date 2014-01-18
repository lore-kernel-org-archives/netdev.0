From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH] tuntap: Fix for a race in accessing numqueue
Date: Sat, 18 Jan 2014 21:43:17 +0400
Message-ID: <52DABD35.3030408@cogentembedded.com>
References: <1390004815-7052-1-git-send-email-dominic.curran@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	Maxim Krasnyansky <maxk@qualcomm.com>
To: Dominic Curran <dominic.curran@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:59819 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaARRnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 12:43:09 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so4438456lan.26
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 09:43:06 -0800 (PST)
In-Reply-To: <1390004815-7052-1-git-send-email-dominic.curran@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-01-2014 4:26, Dominic Curran wrote:

> A patch for fixing a race between queue selection and changing queues
> was introduced in commit 92bb73ea2c434618a68a5.

    Please also specify that commit's summary line in parens.

> The fix was to prevent the driver from re-reading the tun->numqueues
> more than once within tun_select_queue().

> We have been experiancing  'Divide-by-zero' errors in
> tun_net_xmit() since we moved from 3.6 to 3.10, and believe that they
> come from a simular source where the value of tun->numqueues changes
> to zero between the first and second read of tun->numqueues.

> Signed-off-by: Dominic Curran <dominic.curran@citrix.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Maxim Krasnyansky <maxk@qualcomm.com>

WBR, Sergei
