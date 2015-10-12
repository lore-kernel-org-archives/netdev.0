From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/3] net: Pass net into defragmentation
Date: Mon, 12 Oct 2015 09:26:38 +0200
Message-ID: <561B60AE.7010809@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
 <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
 <87si62gteh.fsf_-_@x220.int.ebiederm.org>
 <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
 <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
 <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
 <87fv1jyjcj.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38158 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbJLH0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:26:42 -0400
Received: by wieq12 with SMTP id q12so6146140wie.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 00:26:41 -0700 (PDT)
In-Reply-To: <87fv1jyjcj.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/10/2015 20:42, Eric W. Biederman a =C3=A9crit :
>
> This is the next installment of my work to pass struct net through th=
e
> output path so the code does not need to guess how to figure out whic=
h
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
>
> In netfilter and af_packet we defragment packets in the output path,
> and there is the usual amount of confusion about how to compute which
> net we are processing the packets in.  This patchset clears that
> confusion up by explicitly passing in struct net in ip_defrag,
> ip_check_defrag, and nf_ct_frag6_gather.

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
