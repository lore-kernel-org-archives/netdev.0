From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Please backport 63b46242f707849 [was: Issue with LACP mode in linux
 bonding driver]
Date: Thu, 02 Jul 2015 17:29:38 -0400
Message-ID: <5595AD42.3040903@cumulusnetworks.com>
References: <CADAe=+LvNgHV+crN_+E4xB+Pcz=KSvZpK5ADKzYFjHL2gGJq2Q@mail.gmail.com> <6462.1435284902@famine> <CADAe=+LmF_O5Tw_+kcg35urKBjJJOFZrYs3R2LNkdh-XW6r2ng@mail.gmail.com> <13466.1435353566@famine> <558DE6E2.5080207@cumulusnetworks.com> <CADAe=++oN6FdmzqrzvXvT+83sS6mjSUDedmWMW6Vgh16M50ATA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ajith Adapa <adapa.ajith@gmail.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36015 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbbGBV3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:29:40 -0400
Received: by qgeg89 with SMTP id g89so39096765qge.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:29:39 -0700 (PDT)
In-Reply-To: <CADAe=++oN6FdmzqrzvXvT+83sS6mjSUDedmWMW6Vgh16M50ATA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please back port the following to the LTS trees v3.2, v3.4, v3.10, 
v3.12, v3.14, and v3.18

commit 63b46242f707849a1df10b70e026281bfa40e849
Author: Wilson Kok <wkok@cumulusnetworks.com>
Date:   Mon Jan 26 01:16:59 2015 -0500

     bonding: fix incorrect lacp mux state when agg not active

Sending this to verify the above patch is being backported to the trees 
listed. Have verified this patch does not exist in them currently. The 
patch fixes LACP mux machine state changes which if incorrect can cause 
a partner switch to send duplicate frames to a Linux host. This patch 
has been verified to fix a problem seen on a v3.10 system, and Cumulus 
is shipping this patch on kernel versions as old as v3.2.

Thank you,
-Jon
