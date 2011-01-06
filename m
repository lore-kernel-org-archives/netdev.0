From: Chin Shi Hong <cshong87@gmail.com>
Subject: Use ioctl() to list all network interfaces.
Date: Thu, 6 Jan 2011 23:33:39 +0800
Message-ID: <AANLkTi=Xb4TuKcCd-DgN5ZnYzRHV1RjDScyjRkqyb4P+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:65324 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab1AFPdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 10:33:41 -0500
Received: by eye27 with SMTP id 27so7214518eye.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 07:33:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

The following codes are just part of my application's source codes:

--begin of some codes--
ifconf ifc;
ret = ioctl(n, SIOCGIFCONF,&ifc);
--End of some codes--

My application's role is to display all network interfaces, including
the network interface which are down.

However, with the above codes, my application only display the network
interface which are already up. The network interface which are down
will not be displayed.

So, what can I do to make my application display all network
interfaces, including the network interface which are down?

regards,
