From: "jiangtao.jit" <jiangtao.jit@gmail.com>
Subject: problem with function vlan_get_protocol()
Date: Sun, 17 Jul 2011 12:53:15 +0800
Message-ID: <201107171253127340006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60887 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab1GQExk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 00:53:40 -0400
Received: by iwn6 with SMTP id 6so2223819iwn.19
        for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 21:53:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,all

in file   inclue/linux/if_vlan.h

there is a statement in function vlan_get_protocol()

	if (likely(protop))
		protocol = *protop;

do we need an else branch on pointer protop failed ?  through the else is unlikely 

	if (likely(protop))
		protocol = *protop;
    else
		protocol = proto;

is it necessary ?

thanks


2011-07-17 
jiangtao.jit 

