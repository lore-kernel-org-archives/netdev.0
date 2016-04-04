From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: af_packet: tone down the Tx-ring unsupported spew.
Date: Mon, 04 Apr 2016 21:24:39 +0200
Message-ID: <5702BF77.8090309@iogearbox.net>
References: <20160404191150.GA7224@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43951 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463AbcDDTYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 15:24:43 -0400
In-Reply-To: <20160404191150.GA7224@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2016 09:11 PM, Dave Jones wrote:
> Trinity and other fuzzers can hit this WARN on far too easily,
> resulting in a tainted kernel that hinders automated fuzzing.
>
> Replace it with a rate-limited printk.
>
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
