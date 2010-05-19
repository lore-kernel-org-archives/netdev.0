From: zhou rui <wirelesser@gmail.com>
Subject: how many msi (msi-x) vectors can be setup?
Date: Wed, 19 May 2010 23:18:40 +0800
Message-ID: <AANLkTikT3ThBnO8q3AvhS9t4jUu8npOwYmjY6WUMhseq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:52044 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab0ESPSk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 11:18:40 -0400
Received: by pxi18 with SMTP id 18so823154pxi.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 08:18:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi there:
how many msi (msi-x) vectors can be setup?
the number is limited by hardware resource(nic), or kernel ?
I found that the driver (broadcom 57711 ver 1.5.12) tried to request
16 queues on my kernel2.6.27,but only 2=A0 available
will it be increased if I update the driver or kernel?
and there is a limitiation in the system? if the other devices have
already occupied too many MSI vectors then it is not enough.


thanks
rui
