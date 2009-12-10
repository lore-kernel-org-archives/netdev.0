From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Can't parse ints with stroul()
Date: Wed, 9 Dec 2009 17:12:20 -0800
Message-ID: <9929d2390912091712g6d0543e9y170f21712b9efb7@mail.gmail.com>
References: <20091208173240.19917.99052.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:64592 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbZLJBMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 20:12:13 -0500
Received: by pwj9 with SMTP id 9so2753892pwj.21
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2009 17:12:20 -0800 (PST)
In-Reply-To: <20091208173240.19917.99052.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2009 at 09:32, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>
> A recent change to how int's were being parsed from the command
> line had them being read in with an unsigned int string operator.
> This didn't allow signed numbers from being read in correctly.
> This patch adds a get_uint() routine, and fixes the get_int()
> routine to read in signed values.
>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>

Jeff G. - hold off on this patch.  We have a version 2 in the works,
because we found if the sign bit was set on a uint, this would fail
parsing.

-- 
Cheers,
Jeff
