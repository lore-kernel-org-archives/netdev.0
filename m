From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: mlx5 PF and VF Vlan Restrictions
Date: Thu, 14 Jul 2016 13:57:07 +0530
Message-ID: <CAOYAsNm+Vdhp=pZ6Dt7tw6gocaOZdkBOHC1qyO8CtKhUO12dNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35683 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbcGNI1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 04:27:15 -0400
Received: by mail-wm0-f43.google.com with SMTP id f65so58023395wmi.0
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 01:27:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Can we have VLAN restrictions at both PF and VF level in mlx5 CX4 driver?

For a particular VF, I would like to restrict VLANs from the PF driver

For e.g, Let's say there is VF0. I would like to restrict the allowed
vlans from the VF0 to be one of 10,20,30.

I would like to do this enforcement at the PF driver.

How do i do this?

So if the VF tries to configure any vlan other than 10,20,30, it should fail.

Also how to communicate the vlans that are allowed to the vf from the PF.


Is this feature already implemented in the mlx5 ?

If not, can anyone please help me understand how to do that.


Thanks so much


Best Regards,
Domingo
