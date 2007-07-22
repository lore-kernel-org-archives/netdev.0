From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: NFS mount gives ENETDOWN in -git15
Date: Sun, 22 Jul 2007 16:10:14 -0700
Message-ID: <86802c440707221610i112c3527p40f188f4afcad31c@mail.gmail.com>
References: <200707211531.17750.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	linux-kernel@vger.kernel.org
To: "Andi Kleen" <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.233]:43749 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760682AbXGVXKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 19:10:16 -0400
Received: by qb-out-0506.google.com with SMTP id o24so1029688qba
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 16:10:15 -0700 (PDT)
In-Reply-To: <200707211531.17750.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/21/07, Andi Kleen <ak@suse.de> wrote:
>
> I tried to mount another nfs mount on a system running with nfsroot.
> But I get
>
> # mount basil:/home /basil/home/
> mount: Network is down
>
> The network is not down of course, the system is happily running with nfs root from that
> server. Userland is older SUSE 10.0
>
> Excerpt from strace mount:
>
> -Andi
>

What is your CONFIG_NETDEVICES_MULTIQUEUE in .config?

YH
