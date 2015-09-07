From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ipv6: fix multipath route replace error
 recovery
Date: Mon, 7 Sep 2015 14:03:12 +0200
Message-ID: <55ED7D00.3050202@6wind.com>
References: <1441237466-22302-1-git-send-email-roopa@cumulusnetworks.com>
 <55E95285.6020102@6wind.com> <55ECA62F.9070905@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Michal Kubecek <mkubecek@suse.cz>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34457 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbIGMDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 08:03:15 -0400
Received: by wicfx3 with SMTP id fx3so86308204wic.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 05:03:14 -0700 (PDT)
In-Reply-To: <55ECA62F.9070905@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Michal Kubecek

Le 06/09/2015 22:46, roopa a =C3=A9crit :
> On 9/4/15, 1:12 AM, Nicolas Dichtel wrote:
>> Le 03/09/2015 01:44, Roopa Prabhu a =C3=A9crit :
[snip]
>>> Fixes: 4a287eba2de3 ("IPv6 routing, NLM_F_* flag support: REPLACE a=
nd EXCL
>>> flags support, warn about missing CREATE flag")
>> ECMP was added one year after this patch. The right tag is:
>> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECM=
P)")
> I went back and looked again. It is a recent one 27596472473a ("ipv6:=
 fix ECMP
> route replacement").
The bug you're trying to fix has been introduced by the commit 51ebd318=
1572
("ipv6: add support of equal cost multipath (ECMP)").
Commit 27596472473a ("ipv6: fix ECMP route replacement") didn't try to =
fix this
problem.

Note that the first patch you submitted to fix this pb (cf
http://patchwork.ozlabs.org/patch/362296/) was in June 2014, ie one yea=
r before
the commit 27596472473a.


Regards,
Nicolas
