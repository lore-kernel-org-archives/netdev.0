From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 2/2] geneve: Unregister pernet subsys on module unload.
Date: Wed, 05 Nov 2014 11:08:57 +0100
Message-ID: <5459F739.4090400@6wind.com>
References: <1415072318-64442-1-git-send-email-jesse@nicira.com> <1415072318-64442-2-git-send-email-jesse@nicira.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:57609 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbaKEKJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 05:09:00 -0500
Received: by mail-wi0-f182.google.com with SMTP id d1so1473245wiv.15
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 02:08:59 -0800 (PST)
In-Reply-To: <1415072318-64442-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/11/2014 04:38, Jesse Gross a =C3=A9crit :
> The pernet ops aren't ever unregistered, which causes a memory
> leak and an OOPs if the module is ever reinserted.
>
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
=46ixes: 0b5e8b8eeae4 ("net: Add Geneve tunneling protocol driver")
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
