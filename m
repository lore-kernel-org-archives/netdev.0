From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Can't parse ints with stroul()
Date: Thu, 24 Dec 2009 03:29:38 -0500
Message-ID: <4B332672.7050101@garzik.org>
References: <20091224072208.19670.30391.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:32929 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbZLXI3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 03:29:41 -0500
Received: by yxe17 with SMTP id 17so7463188yxe.33
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2009 00:29:40 -0800 (PST)
In-Reply-To: <20091224072208.19670.30391.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/2009 02:22 AM, Jeff Kirsher wrote:
> From: PJ Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>
> A recent change to how int's were being parsed from the command
> line had them being read in with an unsigned int string operator.
> This didn't allow signed numbers from being read in correctly.
> This patch adds a get_uint() routine, and fixes the get_int()
> routine to read in signed values.
>
> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   ethtool.c |   23 +++++++++++++++++++++--
>   1 files changed, 21 insertions(+), 2 deletions(-)

applied


