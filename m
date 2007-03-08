From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: brctl issue
Date: Thu, 8 Mar 2007 13:14:25 -0800
Message-ID: <20070308131425.3f31c811@freekitty>
References: <20070307160355.0e27f425@dxpl.pdx.osdl.net>
	<DE026503646E7F40AF97BAB98334333B267A1B@uss-republic.finepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bridge@linux-foundation.org>
To: "Hai Wang" <hwang@finepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36381 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933345AbXCHVOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 16:14:36 -0500
In-Reply-To: <DE026503646E7F40AF97BAB98334333B267A1B@uss-republic.finepoint.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Mar 2007 22:30:09 -0500
"Hai Wang" <hwang@finepoint.com> wrote:

> Hello,
>  
>      I have a question regarding brctl and br2684, I have a network scenrio where I have to add br2684-rt into a bridge. but I could not do so with brctl, please let me if you have any suggestion on the issue.
>  
> My scenario :
>  
>                                        (vpi/vci) 
>       192.168.2.16             0/32               nas0
>     DSLAM1 (BR2684-rt)  --------------|-----------------
>        192.168.3.26            0/33                |                         |                                    192.168.1.18
>     DSLAM 2(BR2684-rt)  --------------| nas1 (LINUX)  Eth0     -----------------PC1 (OAM)
>         192.168.4.36            0/34               |                         |
>     DSLAM 3(BR2684-rt)  --------------|nas2------------
>  
>  
>     I want to put nas0, nas1, nas2 and eth0 on a bridge so that PC1 is able to communicate with DSLAMS.
>  
>  
>   Note that we do not want to assign any IP on nas0, nas1 and nas2.
>  
>  
> Please help with your suggestion.
>  

There is support for ATM bridging but never tried it (don't have ATM)
Did you look at?

	http://home.regit.org/?page_id=8
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
