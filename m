From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH for 2.6.24][NET] fs_enet: check for phydev existence in the ethtool handlers
Date: Wed, 9 Jan 2008 23:14:24 +0300
Message-ID: <8496f91a0801091214n88c8d89q65beb1f160146eaa@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linuxppc-embedded@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:13853 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbYAIUOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 15:14:25 -0500
Received: by py-out-1112.google.com with SMTP id u52so578817pyb.10
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2008 12:14:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks!

I had the same problem too. The solution was the following:
http://www.mail-archive.com/netdev@vger.kernel.org/msg37951.html

Also have a look at the potential multicasting recovery problem in
fs_enet driver:
http://patchwork.ozlabs.org/linuxppc/patch?id=10700

Best regards,
Matvejchikov Ilya.
