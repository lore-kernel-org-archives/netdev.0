From: "Gustavo F. Padovan" <gustavo@padovan.org>
Subject: IP/UDP encapsulation
Date: Thu, 8 Apr 2010 04:42:47 -0300
Message-ID: <20100408074247.GA19798@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marco bonola <marco.bonola@gmail.com>,
	"ZioPRoTo (Saverio Proto)" <zioproto@gmail.com>,
	Behling Mario <mb@mariobehling.de>,
	"L. Aaron Kaplan" <aaron@lo-res.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57333 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758539Ab0DHHsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 03:48:42 -0400
Received: by vws13 with SMTP id 13so941576vws.19
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 00:48:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm looking for some advice on that work. The Freifunk organization is
planning work on the IP/UDP encapsulation kernel module as a GSoC
project. The idea is to create a IP-in-UDP tunnel like we do for
IP-in-IP or IP-in-GRE tunnels. The only way to do that today is to use
some VPN software.

The module will export its virtual interface through sockets and will
have support for the standard syscalls like the others encapsulation
modules.

It will improve the performance of mesh networks that will we be able
to use IP-in-UDP rather than IP-in-IP. So, instead of push all data to
local gateway into the mesh all the data can be tunneled to a faster
server and from there to the Internet. With all the data exiting with
the same IP address (the fast server IP). That will improve bandwidth,
especially for upload.

Is such module acceptable for merge into the Linux Kernel?

Any comments or suggestions to the module architecture and
implementation? If you want more information about the module I can
provide that.

Regards,

-- 
Gustavo F. Padovan
http://padovan.org
