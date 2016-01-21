From: Stanislav Makar <smakar@mirantis.com>
Subject: Increasing, decreasing netmask with iproute2
Date: Thu, 21 Jan 2016 22:12:04 +0200
Message-ID: <CANatXy9EF2wQ-BWX9y4ney_4w8ee93OgjACoycFs6-iDP3SU1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38619 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbcAUUMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 15:12:06 -0500
Received: by mail-wm0-f42.google.com with SMTP id b14so99212755wmb.1
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 12:12:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone

I am playing with changing netmask for ip v4 address and find out that
there is no
other possibility to do it except:

ip address add 1.2.3.4/21 dev <device>
ip address del 1.2.3.4/24 dev <device>

Looks like all is working but I would like to get official answer
that this is safe to do in such way?

Look forward to your answer.
Thanks in advance.
