From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 2/6] ethernet: wiznet: remove unnecessary
 check
Date: Thu, 23 Oct 2014 16:23:43 +0400
Message-ID: <5448F34F.30608@cogentembedded.com>
References: <1414029531-5067-1-git-send-email-varkab@cdac.in> <1414029531-5067-3-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:65323 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357AbaJWMXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 08:23:47 -0400
Received: by mail-la0-f44.google.com with SMTP id hs14so744908lab.3
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 05:23:45 -0700 (PDT)
In-Reply-To: <1414029531-5067-3-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/23/2014 5:58 AM, Varka Bhadram wrote:

> devm_ioremap_resource checks platform_get_resource() return value.
> We can remove the duplicate check here.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ethernet/wiznet/w5300.c |    6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)

    Don't do 2 patches with the same subject. Either merge them, or include 
the driver name (which is different in both cases) in the subject.

WBR, Sergei
