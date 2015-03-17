From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 1/3] net: add support for phys_port_name
Date: Tue, 17 Mar 2015 11:54:00 -0700
Message-ID: <55087848.3030109@gmail.com>
References: <1426606258-13466-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
	jiri@resnulli.us, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35052 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbbCQSyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:54:39 -0400
Received: by pabyw6 with SMTP id yw6so17449746pab.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 11:54:39 -0700 (PDT)
In-Reply-To: <1426606258-13466-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/03/15 08:30, David Ahern wrote:
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

Can you also include a documentation update to
Documentation/ABI/testing/sysfs-class-net? Thanks!
-- 
Florian
