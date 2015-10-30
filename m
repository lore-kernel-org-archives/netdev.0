From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCHv3 net 0/2] ipv4: fix problems from the RTNH_F_LINKDOWN
 introduction
Date: Fri, 30 Oct 2015 12:53:27 -0400
Message-ID: <20151030165326.GA8027@gospo.home.greyhouse.net>
References: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:32965 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbbJ3Qxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 12:53:34 -0400
Received: by qgeo38 with SMTP id o38so66775184qge.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 09:53:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 10:23:32AM +0200, Julian Anastasov wrote:
> Fix two problems from the change that introduced RTNH_F_LINKDOWN
> flag. The first patch deals with the removal of local route on
> DOWN event. The second patch makes sure the RTNH_F_LINKDOWN
> flag is properly updated on UP event because the DOWN event
> sets it in all cases.
> 
> v2->v3:
> - use bool for force var
> 
> v1->v2:
> - forgot to add ifconfig dummy0 down in the test case
> - split to 2 patches
> 
> Julian Anastasov (2):
>   ipv4: fix to not remove local route on link down
>   ipv4: update RTNH_F_LINKDOWN flag on UP event

I had a chance to test both of these this morning and they look good.
Sorry for the delay.  Thanks for making force a bool to cover the single
case -- good suggestion by DaveM.

Reviewed-by: Andy Gospodarek <gospo@cumulusnetworks.com>
