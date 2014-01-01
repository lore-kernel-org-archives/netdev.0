From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v3 2/2] netlink: specify netlink packet direction
 for nlmon
Date: Wed, 01 Jan 2014 05:16:49 +0100
Message-ID: <52C396B1.8010503@redhat.com>
References: <1387805756-21121-3-git-send-email-dborkman@redhat.com> <52B8770B.60009@6wind.com> <52B878D7.4020308@redhat.com> <20131231.135008.1712348847039091134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	darkjames-ws@darkjames.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbaAAEQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Dec 2013 23:16:58 -0500
In-Reply-To: <20131231.135008.1712348847039091134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2013 07:50 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Mon, 23 Dec 2013 18:54:31 +0100
>
>> We could entirely remove it as it was e.g. proposed in 2008 [1]
>> already if you see any value in that. Eventually it's up to Dave and
>> if he likes, I'll be happy to send a patch that removes this define.
>
> Removing user visible defines can break source builds, for example
> someone building string tables or auto-generating things to facilitate
> accessing these values from languages other than C.
>
> It's harmless, since nobody semantically expects anything of it, but
> we have to keep it around.

Ok, that's fine by me.

Thanks for applying Dave and a happy new year!

Best,

Daniel
