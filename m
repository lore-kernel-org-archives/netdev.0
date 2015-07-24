From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Fri, 24 Jul 2015 16:11:03 +0200
Message-ID: <55B24777.1090209@6wind.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B101DC.6040609@cumulusnetworks.com> <55B1077F.1090501@6wind.com> <55B10D50.9010704@cumulusnetworks.com> <55B22E64.2010405@6wind.com> <55B24291.1040704@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33640 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbbGXOLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 10:11:07 -0400
Received: by wicmv11 with SMTP id mv11so66451573wic.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 07:11:05 -0700 (PDT)
In-Reply-To: <55B24291.1040704@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2015 15:50, roopa a =E9crit :
> On 7/24/15, 5:24 AM, Nicolas Dichtel wrote:
>> Sure, but my goal was to not create a new .h file just for these two=
 helpers.
>> It's related to lwtunnel, thus I was thinking they can go here.
> ok..., since your lwt namespace functions went into net_namespace.c, =
I was thinking
> these should really go into net_namespace.h. Does that work for you ?
Not so easy, it's a problem of chicken and egg. If I add this to
net/net_namespace.h, I need to include net/lwtunnel.h but this file alr=
eady
includes net/net_namespace.h (included directly or indirectly by most o=
f the
network headers).


Regards,
Nicolas
