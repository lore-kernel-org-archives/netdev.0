From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: ipv6: Fix refcnt on host routes
Date: Thu, 03 Mar 2016 15:41:18 +0100
Message-ID: <56D84D0E.4080103@iogearbox.net>
References: <1456947007-32444-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrey Wagin <avagin@gmail.com>,
	Ying Huang <ying.huang@linux.intel.com>
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48741 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756959AbcCCOlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:41:21 -0500
In-Reply-To: <1456947007-32444-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2016 08:30 PM, David Ahern wrote:
> Andrew and Ying Huang's test robot both reported usage count problems that
> trace back to the 'keep address on ifdown' patch.
>
[...]
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Cc: Andrey Wagin <avagin@gmail.com>
> Cc: Ying Huang <ying.huang@linux.intel.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Fixes the issue as well over here.
