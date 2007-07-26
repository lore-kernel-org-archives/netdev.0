From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/4 -rev1] Add new timeval_to_sec function
Date: Thu, 26 Jul 2007 08:17:20 +0200
Message-ID: <46A83C70.20606@hartkopp.net>
References: <20070726104526.0348e746.varunc@linux.vnet.ibm.com> <46A837FE.5060900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:61913 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbXGZGSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:18:11 -0400
In-Reply-To: <46A837FE.5060900@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Varun Chandramohan a =E9crit :
>>
>> +    return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);
>
> return tv->tv_sec + (tv->tv_usec ? 1 : 0);
>
> is much faster

It additionally wins the design award in opposite to my suggestion ;-)
Thanks!


