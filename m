From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Thu, 7 Dec 2006 08:25:14 -0500
Message-ID: <bdfc5d6e0612070525u320b0b65j161819b730e3b9ac@mail.gmail.com>
References: <20061130162322.GA8772@gospo.rdu.redhat.com>
	 <200611301938.kAUJchgv020451@death.nxdomain.ibm.com>
	 <bdfc5d6e0611301215o3e3e0c73wb22156b57ba7ed0f@mail.gmail.com>
	 <200612050049.kB50nwgv023439@death.nxdomain.ibm.com>
	 <bdfc5d6e0612061801wc276619l3c4b6d498ca4e8fd@mail.gmail.com>
	 <200612070646.kB76kbgv004791@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:9298 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032209AbWLGNZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 08:25:15 -0500
Received: by ug-out-1314.google.com with SMTP id 44so461527uga
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 05:25:14 -0800 (PST)
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <200612070646.kB76kbgv004791@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/7/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>         I don't see a problem in starting with your patch; the end state
> will be sufficiently different (e.g., the four workqueues would
> ultimately be consolidated into one) that it's still a good testbed to
> start with.

My patch actually only uses a single workqueue for each bond (almost
exactly like yours in-fact) with 4 different types of work that can be
placed on it.

>
>         The only other minor issue is that after this week, I will be
> off for the holidays (and far, far away from email) for the next month.
>

Good to know.

>         -J
>
> ---
>         -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
