From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN
Date: Wed, 29 Jul 2015 22:00:35 +0200
Message-ID: <20150729200035.GA26146@pox.localdomain>
References: <bd6d90197964df7c1b8e52ba5d30e9f703355366.1438169322.git.tgraf@suug.ch>
 <CALnjE+qr8JAbm6s5dT0tCAMzFo0PN=mXvcD7zmcKhBvcabvSPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37928 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbbG2UAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 16:00:39 -0400
Received: by wibxm9 with SMTP id xm9so41174706wib.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 13:00:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+qr8JAbm6s5dT0tCAMzFo0PN=mXvcD7zmcKhBvcabvSPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/15 at 12:05pm, Pravin Shelar wrote:
> On Wed, Jul 29, 2015 at 4:52 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > This readds the config option CONFIG_OPENVSWITCH_VXLAN to avoid a
> > hard dependency of OVS on VXLAN. It moves the VXLAN config compat
> > code to vport-vxlan.c and allows compliation as a module.
> >
> > Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> > Fixes: 2661371ace96 ("openvswitch: fix compilation when vxlan is a module")
> > Cc: Pravin B Shelar <pshelar@nicira.com>
> > Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Looks good.
> Once userspace vswitchd can directly configures VXLAN device, we can
> deprecate this vport-vxlan module.
> 
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

Agreed. We should do that once GRE and Geneve are converted as well.
