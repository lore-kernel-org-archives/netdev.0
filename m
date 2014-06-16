From: Albert Krenz <albert.krenz87@googlemail.com>
Subject: How does the linux kernel select the MAC address for TAP devices?
Date: Mon, 16 Jun 2014 10:00:14 +0200
Message-ID: <CAPRaSD6_TUBLNJu3GC84FwWmPOqLnhgmoq61mZX03dJFM8cyrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:53393 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaFPIAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 04:00:15 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so5714579qab.17
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 01:00:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As stated in the email subject: Where does the kernel get the used
MAC-Adress for a newly create TAP device? Are they randomly generated
or does it select one from a fixed pool of reserved MAC-Adresses?

I have not found any official documentation about the selection of
MAC-addresses for TAP-devices. Most sites like
http://backreference.org/2010/03/26/tuntap-interface-tutorial/ state
that the MAC addresses are auto-generated and can be changed. But they
do not explain the generation rules.

Does anyone know an official document (preferably from kernel.org)
explaining the MAC selection process? Or is it only explained in the
Source?
