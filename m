From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] xfrm: new command for configuring SPD hash
Date: Fri, 10 Apr 2015 13:22:32 -0700
Message-ID: <20150410132232.6010d3ff@urahara>
References: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34308 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755947AbbDJUW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:22:28 -0400
Received: by pdbqa5 with SMTP id qa5so33085734pdb.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:22:27 -0700 (PDT)
In-Reply-To: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Apr 2015 17:39:31 +0200
Christophe Gouault <christophe.gouault@6wind.com> wrote:

> This patch adds a new command to configure the SPD hash table:
>    ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]
> 
> and code to display the SPD hash configuration:
>    ip -s -s xfrm policy count
> 
> The second path updates ip xfrm man page.
> 
> Best Regards,
> Christophe
> --
>  ip/xfrm_policy.c   |  105 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  man/man8/ip-xfrm.8 |   61 ++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 161 insertions(+), 5 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Applied to net-next branch of iproute2
