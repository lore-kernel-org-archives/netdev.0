From: Thomas Tanaka <thomas.tanaka@gmail.com>
Subject: Exporting some of sysctls from net/ipv4 and net/core to a net namespace
Date: Wed, 14 Oct 2015 17:55:57 -0700
Message-ID: <CAEQGt1L5aDJ0ohM0PvFs6_dziOo=fSjVhGsxcjBgYsCvFN0ofw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37175 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbbJOA4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 20:56:18 -0400
Received: by igbhv6 with SMTP id hv6so30055354igb.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 17:56:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems due to the following patch set in Linux v3.5
[PATCH net-next 00/19] net: Sysctl simplications and enhancements
http://comments.gmane.org/gmane.linux.network/227965
some of the previously visible sysctls variables in net/core and
net/ipv4 has become invisible.

Is there a possibility that the idea of bringing back some of those
parameters as a read-only to a net namespace be considered ?

Thanks in advance.

-- 
Regards,

Thomas
