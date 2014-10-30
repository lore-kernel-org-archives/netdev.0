From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Identify a lot of netlink protocol names
Date: Wed, 29 Oct 2014 22:49:32 -0700
Message-ID: <20141029224932.0df2edba@urahara>
References: <1413478018-12373-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:47503 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbaJ3Fto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 01:49:44 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so4450331pdb.7
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 22:49:43 -0700 (PDT)
In-Reply-To: <1413478018-12373-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Oct 2014 19:46:58 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> There were only few Netlink protocol names:
> 
>     rtnl, fw, tcpdiag
> 
> which were printed on output.
> So added the other ones.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Please make this driven off of a file in /etc/iproute2/ rather than
hard coding a big switch in the code.
