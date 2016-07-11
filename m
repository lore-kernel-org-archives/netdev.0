From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 2/4] net/mlx4: Preparation for VST QinQ
Date: Mon, 11 Jul 2016 13:33:04 +0300
Message-ID: <a19f0939-91a6-190e-8af6-189987c0d57d@gmail.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com>
 <1467808146-29573-3-git-send-email-tariqt@mellanox.com>
 <CAJ3xEMhi=jY=tisExuwe1HEeftr4fLE5uqWOD9De+UoR4AYEqA@mail.gmail.com>
 <AM4PR05MB15534E2234C21C803C2B8FD0AE3E0@AM4PR05MB1553.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37836 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758428AbcGKKdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 06:33:08 -0400
Received: by mail-wm0-f51.google.com with SMTP id i5so9953056wmg.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 03:33:08 -0700 (PDT)
In-Reply-To: <AM4PR05MB15534E2234C21C803C2B8FD0AE3E0@AM4PR05MB1553.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2016 7:00 PM, Tariq Toukan wrote:
>>> Add func capability vlan_offload_disable to disable all vlan HW
>>> acceleration on VF while the VF is set to VST QinQ mode.
>> this part (above two lines) is code running in the VF Eth driver, correct? if this is indeed the case, break the patch to two (1) PF core driver  (2) VF core/EN driver
>>
>> What happens if the VF doesn't work as you expect? e.g the PF runs your code and the VF driver is unpatched?
> Good point, currently if the administrator sets the configuration then it just silently not fail. We will use a mechanism that prevents this.
* silently fails
