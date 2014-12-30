From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Tue, 30 Dec 2014 16:26:43 +0800
Message-ID: <54A261C3.1060805@oracle.com>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com>	<CAHA+R7M-Nm_R-AaKQ0nX4L3O=BN5_m1v-8sWJSaE_UmGyo8zwA@mail.gmail.com>	<54A21596.7000706@oracle.com> <20141229.232507.2086816594770925202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29552 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbaL3IZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 03:25:14 -0500
In-Reply-To: <20141229.232507.2086816594770925202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B412=E6=9C=8830=E6=97=A5 12:25, David Miller =E5=86=
=99=E9=81=93:
> From: Wengang <wen.gang.wang@oracle.com>
> Date: Tue, 30 Dec 2014 11:01:42 +0800
>
>> There are more than one way we do things. For this case, considering
>> needs, complexity and stability I think moving ipoib_header_ops is t=
he
>> right way to go.
> I completely disagree, it's a gross hack at best.
>
> It's papering over the real problem.
>
> When we have references to released objects in other areas of the
> networking stack, we don't move those objects into the static kernel
> image as a fix.

OK. Let me see if I can make a patch to match what you want.

Thanks
wengang
