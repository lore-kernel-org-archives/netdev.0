From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: AF_PACKET how to get the original netdev from a packet received from a bonded master
Date: Wed, 18 Apr 2007 17:17:45 -0700
Message-ID: <41b516cb0704181717l2c6c15a0j9ae275d15c6b22f4@mail.gmail.com>
References: <97949e3e0704181605v39e24bh18ac278adc8b823f@mail.gmail.com>
	 <20070418.162523.68157230.davem@davemloft.net>
	 <41b516cb0704181652o6a05b570t511ee23373a0b3ac@mail.gmail.com>
	 <20070418.170749.07021824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:13485 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993021AbXDSARq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 20:17:46 -0400
Received: by nz-out-0506.google.com with SMTP id s1so301028nze
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2007 17:17:45 -0700 (PDT)
In-Reply-To: <20070418.170749.07021824.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/07, David Miller <davem@davemloft.net> wrote:
> Ok, it will give you one level of decapsulation.
>
> What do we tell people who want 2 devices previous? :-)

I can tell you that the intent of PJs patch was to provide the ifindex
of the physical interface that a packet entered the system on,
regardless of how many layers of encapsulation are involved.

Of course it may not actually do that ...
