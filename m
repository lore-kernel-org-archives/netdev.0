From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Tue, 05 Aug 2014 17:16:20 +0200
Message-ID: <53E0F544.4020504@redhat.com>
References: <1406837476-13776-1-git-send-email-dborkman@redhat.com> <20140731.222804.1403723639172562683.davem@davemloft.net> <53DF56F1.4020701@redhat.com> <20140804.114146.2155043446693665715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	akinobu.mita@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbaHEPQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 11:16:28 -0400
In-Reply-To: <20140804.114146.2155043446693665715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2014 08:41 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Mon, 04 Aug 2014 11:48:33 +0200
>
>> Akinobu and I also tested this patch with the above fix included,
>> and it runs through the 3 relevant test cases _without_ any errors
>> on the nandsim device (simulator for MTD devs):
>
> On one endianness only perhaps?

On x86_64, ppc64, ARM (i.MX28, i.MX53 and i.MX6).
