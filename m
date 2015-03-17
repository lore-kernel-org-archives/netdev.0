From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 1/3] net: add support for phys_port_name
Date: Mon, 16 Mar 2015 22:59:28 -0700
Message-ID: <CAE4R7bBit0e2xzKOa1KVsGMguDR0MMHtgTbOFdBg0=i-EPe6Hg@mail.gmail.com>
References: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:34134 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbCQF73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 01:59:29 -0400
Received: by qcaz10 with SMTP id z10so64892411qca.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 22:59:28 -0700 (PDT)
In-Reply-To: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 8:27 PM, David Ahern <dsahern@gmail.com> wrote:
> Similar to port id allow netdevices to specify port names and export
> the name via sysfs. Drivers can implement the netdevice operation to
> assist udev in having sane default names for the devices using the
> rule:
>
> $ cat /etc/udev/rules.d/80-net-setup-link.rules
> SUBSYSTEM=="net", ACTION=="add", ATTR{phys_port_name}!="",
> NAME="$attr{phys_port_name}"
>
> Use of phys_name versus phys_id was suggested-by Jiri Pirko.
>
> v2:
> - replaced netdev_phys_item_name with buffer and length per Jiri's comment
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Scott Feldman <sfeldma@gmail.com>


Acked-by: Scott Feldman <sfeldma@gmail.com>
