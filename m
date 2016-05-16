From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH 1/1] tc fix ife late binding
Date: Mon, 16 May 2016 11:16:50 -0700
Message-ID: <20160516111650.0f7285fb@xeon-e3>
References: <1462721329-27987-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33369 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbcEPSQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:16:38 -0400
Received: by mail-pf0-f171.google.com with SMTP id 206so70384389pfu.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:16:37 -0700 (PDT)
In-Reply-To: <1462721329-27987-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  8 May 2016 11:28:49 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> following late action binding didn't work:
> 
> sudo tc actions add action ife encode \
> type 0xDEAD allow mark dst 02:15:15:15:15:15 index 1
> 
> sudo tc filter add dev lo parent ffff: protocol ip prio 2 u32\
> match ip src 127.0.0.2/32 flowid 1:2 action ife index 1
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Ok, applied all the ife patches (for 4.6)
