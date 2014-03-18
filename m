From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] VXLAN: fix potential NULL dereference in arp_reduce()
Date: Tue, 18 Mar 2014 10:36:26 -0700
Message-ID: <CAHA+R7OXfX+QYt=+Nm1vCDzyX7dJtpgDtqEjgPTSO=B8Er915Q@mail.gmail.com>
References: <201403181632.s2IGWTjT003613@lab1.dls>
	<CAHA+R7O+Njk2vbfEg+RfrRJ=x1JdXTheZQwhu4PpU47Bgk2CHQ@mail.gmail.com>
	<OF6DB4D166.F9450AC6-ON87257C9F.005D2CBF-87257C9F.005D2CC2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:45298 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757AbaCRRg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:36:27 -0400
Received: by mail-lb0-f181.google.com with SMTP id c11so4916388lbj.26
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:36:26 -0700 (PDT)
In-Reply-To: <OF6DB4D166.F9450AC6-ON87257C9F.005D2CBF-87257C9F.005D2CC2@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 9:57 AM, David Stevens <dlstevens@us.ibm.com> wrote:
>
>
>>From: Cong Wang
>
>>
>>Nit: move it right after arp_create(). Otherwise:
>>
>
> That would exit without releasing the neighbor reference.
>

Ah, then it's ok.
