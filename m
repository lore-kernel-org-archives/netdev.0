From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 1/3] net: add support for phys_port_name
Date: Tue, 24 Mar 2015 15:13:18 -0700
Message-ID: <20150324151318.4e50dcbb@urahara>
References: <1426645397-15284-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33411 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbCXWNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:13:15 -0400
Received: by pabxg6 with SMTP id xg6so6905077pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:13:15 -0700 (PDT)
In-Reply-To: <1426645397-15284-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2015 20:23:15 -0600
David Ahern <dsahern@gmail.com> wrote:

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
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Scott Feldman <sfeldma@gmail.com>

Should this also be settable as well?
