From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/4] net/mlx4: Preparation for VST QinQ
Date: Thu, 7 Jul 2016 23:02:47 +0300
Message-ID: <CAJ3xEMhi=jY=tisExuwe1HEeftr4fLE5uqWOD9De+UoR4AYEqA@mail.gmail.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com> <1467808146-29573-3-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36538 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbcGGUCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 16:02:49 -0400
Received: by mail-oi0-f47.google.com with SMTP id f189so38180516oig.3
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 13:02:48 -0700 (PDT)
In-Reply-To: <1467808146-29573-3-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 3:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Moshe Shemesh <moshe@mellanox.com>
>
> Check device capability to support VST QinQ mode.
> Add vport attribute vlan protocol.
> Init vport vlan protocol by default to 802.1Q.
> Add update QP support for VST QinQ.


> Add func capability vlan_offload_disable to disable all
> vlan HW acceleration on VF while the VF is set to VST QinQ mode.

this part (above two lines) is code running in the VF Eth driver,
correct? if this is indeed the case, break the patch to two (1) PF
core driver  (2) VF core/EN driver

What happens if the VF doesn't work as you expect? e.g the PF runs
your code and the VF driver is unpatched?
