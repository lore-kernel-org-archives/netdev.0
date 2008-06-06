From: "Or Gerlitz" <or.gerlitz@gmail.com>
Subject: Re: [RFC v2 PATCH 3/3] net/bonding: deliver netdev event for fail-over under the active-backup mode
Date: Fri, 6 Jun 2008 21:56:38 +0300
Message-ID: <15ddcffd0806061156u487ccf6erde0889174b1ca284@mail.gmail.com>
References: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
	 <Pine.LNX.4.64.0806021344270.31515@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Or Gerlitz" <ogerlitz@voltaire.com>, netdev@vger.kernel.org
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:63378 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbYFFS4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 14:56:45 -0400
Received: by fg-out-1718.google.com with SMTP id 19so751998fgg.17
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 11:56:43 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0806021344270.31515@zuben.voltaire.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/2/08, Or Gerlitz <ogerlitz@voltaire.com> wrote:
>  - changes from v1
>   * set correct locking context for the notifier call
>   * with these unlockings I don't see any more the "scheduling while atomic" warnings

Jay,

Can you comment on the patches? I'd like to get this into 2.6.27 and I
have a patch set to the rdma stack which is dependent on delivering
the event by bonding, so I'd like to know where things are.

thanks,

Or.
