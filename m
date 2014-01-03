From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCHv2 net] {vxlan,inet6} Mark vxlan_dev flags with
 VXLAN_F_IPV6 properly
Date: Thu, 2 Jan 2014 20:00:49 -0800
Message-ID: <CAM_iQpX9a5fYPRuxND1XdX0V3+ceuksS00JsFgyzN=M-xy95OA@mail.gmail.com>
References: <1388715538-27385-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: rcwhelan@gmail.com, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:48249 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaACEAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 23:00:49 -0500
Received: by mail-ob0-f179.google.com with SMTP id wm4so15277666obc.10
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 20:00:49 -0800 (PST)
In-Reply-To: <1388715538-27385-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 6:18 PM, Fan Du <fan.du@windriver.com> wrote:
> Even if user doesn't supply the physical netdev to attach vxlan dev
> to, and at the same time user want to vxlan sit top of IPv6, mark
> vxlan_dev flags with VXLAN_F_IPV6 to create IPv6 based socket.
> Otherwise kernel crashes safely every time spitting below messages,
>
> Steps to reproduce:
> ip link add vxlan0 type vxlan id 42 group ff0e::110
> ip link set vxlan0 up
>
...
>
> Signed-off-by: Fan Du <fan.du@windriver.com>
> Reported-by: Ryan Whelan <rcwhelan@gmail.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
