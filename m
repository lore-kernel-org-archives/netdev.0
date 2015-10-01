From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/6] net: Pass net through ip fragmention
Date: Thu, 1 Oct 2015 10:33:29 +0200
Message-ID: <560CEFD9.1050200@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
 <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
 <87si62gteh.fsf_-_@x220.int.ebiederm.org>
 <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36223 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbbJAIdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 04:33:32 -0400
Received: by wicgb1 with SMTP id gb1so18024579wic.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 01:33:31 -0700 (PDT)
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/09/2015 23:24, Eric W. Biederman a =C3=A9crit :
>
> This is the next installment of my work to pass struct net through th=
e
> output path so the code does not need to guess how to figure out whic=
h
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
>
> This round focuses on passing net through ip fragmentation which we s=
eem
> to call from about everywhere.  That is the main ip output paths, the
> bridge netfilter code, and openvswitch.  This has to happend at once
> accross the tree as function pointers are involved.
>
> First some prep work is done, then ipv4 and ipv6 are converted and th=
en
> temporary helper functions are removed.
Some minors comments (see other emails).

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
