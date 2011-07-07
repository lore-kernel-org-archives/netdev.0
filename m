From: lists+linux-netdev@corpit.ru
Subject: Re: [heads-up] bridge in kernel 3.0~ and dhcp from kvm guest on tap
 device
Date: Thu, 07 Jul 2011 13:55:41 +0400
Message-ID: <4E15829D.1020307@msgid.corpit.ru>
References: <4E158019.9040604@msgid.tls.msk.ru> <20110707.024906.763895385840201032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110707.024906.763895385840201032.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

07.07.2011 13:49, David Miller wrote:
> From: Michael Tokarev <mjt@tls.msk.ru>
> Date: Thu, 07 Jul 2011 13:44:57 +0400
> 
>> The combination in $subject apparently stopped working --
>> I'm running 3.0-rc6 kernel on host where it doesn't work.
> 
> Already fixed in net-2.6:
> 
> From 44661462ee1ee3c922754fc1f246867f0d01e7ea Mon Sep 17 00:00:00 2001
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 5 Jul 2011 13:58:33 +0000
> Subject: [PATCH 24/30] bridge: Always flood broadcast packets

Thank you very much for the quick response!  I was preparing
myself for another painful bisection session for tonight
already.. ;)

I just verified - this patch fixes this issue (I rebuilt and
re-loaded the module) -- hopefully the fix will be in 3.0
kernel ;)

Thanks!

/mjt
