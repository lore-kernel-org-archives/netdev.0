From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Thu, 30 Jun 2016 17:24:58 +0300
Message-ID: <CAJ3xEMhtPNtcjKCW8cu9nMS04KNnMxs+XzqvQMWntxLJ_mr7YQ@mail.gmail.com>
References: <0327b6de-dfdf-8db2-1354-b7a4144dbc02@mellanox.com>
 <5773F8CC.4090300@gmail.com> <CAJ3xEMgGCW_P-sb3pe1KqMVoKe4BWKoO88_O364nwEU6bDnaoA@mail.gmail.com>
 <577446FE.7060402@gmail.com> <5774938D.7010902@gmail.com> <57749A57.1030709@gmail.com>
 <20160630062516.GA2569@nanopsycho.orion> <5774C6B3.1000901@intel.com>
 <20160630074154.GC2569@nanopsycho.orion> <5774D0E1.4070605@gmail.com> <20160630105212.GD2569@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33907 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbcF3O0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 10:26:45 -0400
Received: by mail-oi0-f42.google.com with SMTP id s66so66926038oif.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 07:25:00 -0700 (PDT)
In-Reply-To: <20160630105212.GD2569@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 1:52 PM, Jiri Pirko <jiri@resnulli.us> wrote:

> Why not to have 2 modes:

> 1) lagacy - the current solution, blackbox eswitch, undefined behaviour
> 2) switchdev - with representors, all features possible as on physical
> switches, whitebox eswitch configured using standard tools?

yep, this makes sense to me. I will rename the offloads mode to be
called switchdev
and we'll respin V2 with few more small fixes and clarification on the
change log of this patch
