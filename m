From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN
Date: Wed, 29 Jul 2015 12:05:49 -0700
Message-ID: <CALnjE+qr8JAbm6s5dT0tCAMzFo0PN=mXvcD7zmcKhBvcabvSPA@mail.gmail.com>
References: <bd6d90197964df7c1b8e52ba5d30e9f703355366.1438169322.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36427 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbbG2TFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 15:05:49 -0400
Received: by ioeg141 with SMTP id g141so31436694ioe.3
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 12:05:49 -0700 (PDT)
In-Reply-To: <bd6d90197964df7c1b8e52ba5d30e9f703355366.1438169322.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 4:52 AM, Thomas Graf <tgraf@suug.ch> wrote:
> This readds the config option CONFIG_OPENVSWITCH_VXLAN to avoid a
> hard dependency of OVS on VXLAN. It moves the VXLAN config compat
> code to vport-vxlan.c and allows compliation as a module.
>
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Fixes: 2661371ace96 ("openvswitch: fix compilation when vxlan is a module")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks good.
Once userspace vswitchd can directly configures VXLAN device, we can
deprecate this vport-vxlan module.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
