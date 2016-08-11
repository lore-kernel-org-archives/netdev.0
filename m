From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] lwtunnel, mpls fragmentation and gso fixes
Date: Thu, 11 Aug 2016 06:49:53 -0700
Message-ID: <57AC8281.2040504@cumulusnetworks.com>
References: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, buytenh@wantstofly.org,
	ebiederm@xmission.com, rshearma@brocade.com,
	simon.horman@netronome.com, tom@herbertland.com, tgraf@suug.ch,
	olivier.dugeon@orange.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32995 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbcHKNt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:49:56 -0400
Received: by mail-pa0-f50.google.com with SMTP id ti13so1200089pac.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 06:49:56 -0700 (PDT)
In-Reply-To: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/16, 11:43 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This series fixes a few issues around mtu and fragmentation
> for tunnels using lwtunnel output redirect and also fixes
> a few gso issues recently reported by Lennert Buytenhek.
>
> David Ahern (2):
>   net: mpls fixes for GSO
>   net: veth: set features for MPLS
>
> Roopa Prabhu (1):
>   lwtunnel: xmit redirect
>
>
I see kbuild test robot reporting some compile errors.
I must have screwed up the submission last night and
in a hurry to get some more review i did not test it with other configs. sorry about that.
will fix these + any other pending review comments and send out a v2 later today.

thanks,
Roopa
