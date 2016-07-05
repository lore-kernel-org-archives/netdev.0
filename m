From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: mlx5 SRIOV VLAN support
Date: Tue, 5 Jul 2016 13:07:46 +0530
Message-ID: <CAOYAsN=5VQM-QF+vnx=p1DtDV+912QO9kwDE-wszXmTJLc4uGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34898 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbcGEHhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 03:37:47 -0400
Received: by mail-pf0-f193.google.com with SMTP id t190so18335068pfb.2
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 00:37:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is VLAN supported in SRIOV mode for mlx5?


Can anyone please help me to:

Enable VLAN guest tagging in mlx5 PF driver?

Do I need to add any E-switch rules to do the same?


My requirement is something like this:


mlx5 VF driver<--------------->mlx5 PF
driver<------------------------->Network<-----------> mlx5 dedicated
driver(non-sriov)



I would like to be able to send ICMP traffic between mlx5 VF driver
and mlx5 dedicated driver.

My understanding is I should be able to do without adding any rules in
the E-switch on the PF driver as by default all traffic is allowed.

Is this correct?


I tried but as this didn't work. I added ingress rules to allow VLAN
traffic and also egress rules to the E-switch ACL tables.

But still i cannot see any traffic between mlx5 VF driver and mlx5
dedicated driver.

I can see that the packets reach the CX4 adapter (mlx5 VF/mlx5 PF) but
they don't go out on the network.

i tried configuring vlan using ip link add dev enp1s0f0 name
enp1s0f0.100 type vlan id 100 on both the mlx5 vf driver and mlx5
dedicated driver.


Can anyone please help!!



Thanks

Best Regards,
Domingo
