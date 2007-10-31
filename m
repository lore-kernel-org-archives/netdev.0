From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: [possibly OT] for_each_netdev() in 2.6.23-gitX / 2.6.24-rc1-gitY breaks Cisco VPN client
Date: Wed, 31 Oct 2007 01:35:47 +0100
Message-ID: <5a4c581d0710301735h1682a30bvfbee632c118556d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:42215 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbXJaAft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 20:35:49 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1797997nfb
        for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 17:35:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's been a while I noticed, but I thought someone would as usual
 cook up some fix, while I don't even see the issue been reported...
 if this isn't a Linux kernel/net issue just drop my email, thanks.

Error message during cisco_vpn.ko build:

/download/linux/net/vpnclient/interceptor.c:345:23: error: macro
"for_each_netdev" requires 2 arguments, but only 1 given

 seems like for_each_netdev() now also uses init_net. If there is
 an alternative and somebody could point me to that, it'd be great,
 as understanding the issue is well out of my grasp.

Patching up the vpnclient source to use init_net gets me to depmod
 complaining it's not allowed to use a GPL-only symbol (init_net)
 in a proprietary module. If this is meant to be - fine, and apologies
 for the waste of bandwidth; but if this is simply an unwanted side
 effect of the recent changes, perhaps it's a good idea to have it
 at least reported.

--alessandro

 "you feel the sweet breath of time
  it's whispering, its truth not mine"

   (Interpol, 'No I In Threesome')
