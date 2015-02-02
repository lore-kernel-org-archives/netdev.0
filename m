From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Mon, 02 Feb 2015 15:09:55 -0700
Message-ID: <54CFF5B3.7070509@gmail.com>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com> <CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com> <54CFEF20.8060300@gmail.com> <54CFF420.3090603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:52089 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964916AbbBBWJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 17:09:57 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so20188936igb.2
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 14:09:56 -0800 (PST)
In-Reply-To: <54CFF420.3090603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/15 3:03 PM, Florian Fainelli wrote:
> Why not? virtio and rocker interfaces are backed by different devices
> drivers which should allow you to use that to name interfaces
> differently. In the case of rocker, you would probably want to read the
> phys_port_id sysfs attribute to name them after their parent switch id too.

[root@f21 ~]# cat /sys/devices/virtual/net/sw5p0/phys_port_id
cat: /sys/devices/virtual/net/sw5p0/phys_port_id: Operation not supported

But in general I guess need to find time to figure out systemd-udev files.

David
