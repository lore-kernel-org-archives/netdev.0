From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: ipconfgi: add declaration for ic_addrservaddr
Date: Thu, 09 Jun 2016 13:35:05 +0200
Message-ID: <57595469.7010708@iogearbox.net>
References: <1465470466-11379-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44288 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFILfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 07:35:30 -0400
In-Reply-To: <1465470466-11379-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2016 01:07 PM, Ben Dooks wrote:
> The symbol ic_addrservaddr is not static, but has no declaration
> to match. Since the similar variables are all exported, add this
> one to the header file as well.
>
> This fixes the following warning:
>
> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not declared. Should it be static?
>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Well, how about making it actually static if it's only used
from ipconfig.c ?
