From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 11/23] switchdev: add new switchdev bridge
 setlink
Date: Sat, 9 May 2015 20:48:51 +0200
Message-ID: <20150509184851.GC2290@nanopsycho>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
 <1431193225-807-12-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35402 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbEIStA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 14:49:00 -0400
Received: by widdi4 with SMTP id di4so63771591wid.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 11:48:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431193225-807-12-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2015 at 07:40:13PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Add new switchdev_port_bridge_setlink that can be used by drivers
>implementing .ndo_bridge_setlink to set switchdev bridge attributes.
>Basically turn the raw rtnl_bridge_setlink netlink into switchdev attr
>sets.  Proper netlink attr policy checking is done on the protinfo part of
>the netlink msg.
>
>Currently, for protinfo, only bridge port attrs BR_LEARNING and
>BR_LEARNING_SYNC are parsed and passed to port driver.
>
>For afspec, VLAN objs are passed so switchdev driver can set VLANs assigned
>to SELF.  To illustrate with iproute2 cmd, we have:
>
>	bridge vlan add vid 10 dev sw1p1 self master
>
>To add VLAN 10 to port sw1p1 for both the bridge (master) and the device
>(self).
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
