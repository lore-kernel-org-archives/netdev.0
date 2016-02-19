From: Marcus Furlong <furlongm@gmail.com>
Subject: iproute2 query
Date: Fri, 19 Feb 2016 20:12:04 +1100
Message-ID: <CAH4CTx4zv_zEgdJYLehReC=JU0-uuWgVNRyLgSjS5CwhY8c2iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35566 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948055AbcBSJMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 04:12:24 -0500
Received: by mail-qg0-f46.google.com with SMTP id y89so56857965qge.2
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 01:12:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Just wondering if the following command should work:

# ip route add 192.168.27.27/24 dev eth0 scope link src 192.168.27.27
RTNETLINK answers: Invalid argument

However, this command works:

# ip route add 192.168.27.0/24 dev eth0 scope link src 192.168.27.27

192.168.27.0/24 and 192.168.27.27/24 describe the same subnet?

Regards,
Marcus.

-- 
Marcus Furlong
