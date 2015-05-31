From: Harsh Jain <harshjain.prof@gmail.com>
Subject: packet encryption based on gre key value with ip xfrm command
Date: Mon, 1 Jun 2015 01:51:05 +0530
Message-ID: <CAFXBA=miJQvBF=zP1=RGoq4fFi0ib-68DJOxLG8QpXXYPP-ACQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:32899 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbEaUVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 16:21:07 -0400
Received: by labpy14 with SMTP id py14so76520808lab.0
        for <netdev@vger.kernel.org>; Sun, 31 May 2015 13:21:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to encrypt Gre packet have specific key values in GRE
header with following command

ip xfrm policy add src 192.168.1.9 dst 192.168.1.5 proto gre key 3 dir
in tmpl src 192.168.1.9 dst 192.168.1.5 proto esp reqid 16387 mode
transport


But it is not working. If I remove the "key 3" from above system
encrypt all GRE packets.

I tried with kernel version 3.18 and iproute2 version.2.4.

 I got iproute2 patch file having changes to support filtering based
on keys but didn't find corresponding kernel patch.
How to encrypt Packets based on GRE key value.?


Regards
Harsh Jain
