From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 4/5] net: sctp: improve sctp_select_active_and_retran_path
 selection
Date: Wed, 11 Jun 2014 17:25:23 +0200
Message-ID: <539874E3.2010607@redhat.com>
References: <1402499003-29355-1-git-send-email-dborkman@redhat.com> <1402499003-29355-5-git-send-email-dborkman@redhat.com> <539873E2.3020003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048AbaFKPZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 11:25:29 -0400
In-Reply-To: <539873E2.3020003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 05:21 PM, Vlad Yasevich wrote:
> On 06/11/2014 11:03 AM, Daniel Borkmann wrote:
>> In case we neither found a possible ACTIVE or UNKNOWN trans_pri
>> resp. trans_sec from our current transport list, we currently
> ^^^^^^
>
> Not sure what you wanted to say here.

Actually just the case of trans_pri == NULL, trans_sec == NULL
since they weren't updated when traversing the list, sorry if
this was unclear.
