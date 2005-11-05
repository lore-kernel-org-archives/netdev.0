From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] kill 8139too kernel thread (sorta)
Date: Fri, 04 Nov 2005 23:58:31 -0500
Message-ID: <436C3BF7.1080906@pobox.com>
References: <20051031130255.GA26626@havoc.gtf.org> <E1EWgcG-0001dZ-00@gondolin.me.apana.org.au> <20051031211143.GA6409@gondor.apana.org.au> <436C2B47.3030505@pobox.com> <20051105042008.GA25823@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751209AbVKEE6e@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051105042008.GA25823@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> My only concern is the potential for starvation here should we fail
> to obtain the RTNL.  Since any local user can hold the RTNL by issuing
> rtnetlink requests, it is theoretically possible for the rtl8139 work
> to be delayed indefinitely.

Yes, but highly unlikely, for very few users, with the negative effects 
negligible.

	Jeff
