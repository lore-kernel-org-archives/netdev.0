From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vxlan: fix a out of bounds access in __vxlan_find_mac
Date: Fri, 29 Jan 2016 14:38:46 -0800
Message-ID: <1454107126.7627.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
	 <CAM_iQpUoB0VH_c3OFMo4Dxrnrzie89jB0u=tceeqJjQgnr5PMQ@mail.gmail.com>
	 <1454104896.7627.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpUFHcX+=R9H5iO1HZLcnbaX=QEzDnRMUYqH+d3NeF7vQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32824 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755963AbcA2Wir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:38:47 -0500
Received: by mail-pf0-f171.google.com with SMTP id x125so49232928pfb.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 14:38:47 -0800 (PST)
In-Reply-To: <CAM_iQpUFHcX+=R9H5iO1HZLcnbaX=QEzDnRMUYqH+d3NeF7vQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 14:17 -0800, Cong Wang wrote:

> Because we have to fix all the cases that don't

Sure, lets do that without removing the optimizations.

macvlan control path seems to need a fix, as you pointed out.
