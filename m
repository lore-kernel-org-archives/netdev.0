From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] qlcnic: Do not force adapter to perform LRO
 without destination IP check
Date: Fri, 25 Oct 2013 21:17:08 -0700
Message-ID: <1382761028.4032.36.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1382711917-28501-2-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:55085 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab3JZERL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 00:17:11 -0400
Received: by mail-ee0-f44.google.com with SMTP id c4so1896511eek.17
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 21:17:10 -0700 (PDT)
In-Reply-To: <1382711917-28501-2-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 10:38 -0400, Shahed Shaikh wrote:
> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Forcing adapter to perform LRO without destination IP check
> degrades the performance.


Hmm... the performance, or does it allow two packets belonging to
different flows being wrongly aggregated ?

It looks a critical bug fix, not only a performance issue.
