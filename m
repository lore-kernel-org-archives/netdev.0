From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from veth_newlink()
Date: Fri, 22 Apr 2011 11:44:28 +0200
Message-ID: <BANLkTin-m+bBjRXUZbYqhNvRadec2ZQFHA@mail.gmail.com>
References: <20110124154546.GA2689@psychotron.brq.redhat.com> <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, xemul@openvz.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56391 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab1DVJos convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 05:44:48 -0400
Received: by qwk3 with SMTP id 3so215511qwk.19
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 02:44:48 -0700 (PDT)
In-Reply-To: <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 22 kwietnia 2011 11:43 u=BFytkownik Micha=B3 Miros=B3aw
<mirqus@gmail.com> napisa=B3:
> 2011/1/24 Jiri Pirko <jpirko@redhat.com>:
>> The code is not needed because tb[IFLA_IFNAME] is already
>> processed in rtnl_newlink(). Remove this redundancy.
> Hi. This patch broke creation of veth devices. Reverting it fixes the=
 issue.

This is commit 84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743.

Best Regards,
Micha=B3 Miros=B3aw
