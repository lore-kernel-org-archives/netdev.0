From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 10:48:25 -0700
Message-ID: <20130515104825.5cbeaee3@nehalam.linuxnetplumber.net>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:62210 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759830Ab3EORs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 13:48:28 -0400
Received: by mail-pd0-f174.google.com with SMTP id u10so1579127pdi.19
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 10:48:28 -0700 (PDT)
In-Reply-To: <OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 May 2013 13:19:43 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> 1) The kernel binds to 8472 on module load.
> 2) After it's bound, iproute2 "changes" the port to 4789, but
>         the kernel binding is still 8742 for listening. All destinations 
> use
>         the new port, but all bindings use the old port.

Sorry, this is a kernel bug.
Kernel shouldn't bind on module load, needs to do it later when
device is created. I will fix.
