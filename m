From: Eric Xiong <bottomofstack@gmail.com>
Subject: Why not refresh ipv6 local link address of a bridge when a new
 interface added to the bridge?
Date: Tue, 20 Sep 2011 10:39:31 +0800
Message-ID: <CA+UXGK3yQzUuZwHWooxd91G77ACvYzwTQUOoDdVc-=CCEv4POQ@mail.gmail.com>
References: <CA+UXGK1Ej4DeS5-=FO0ejMCGjWfptxxxRibhMi2-duE9Cx2D_g@mail.gmail.com>
	<CA+UXGK1XAgCxYUoOAP6yQSGhzDB-3p3oDqOoOc_e=rTT3DPx7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63623 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab1ITCpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 22:45:11 -0400
Received: by yxl31 with SMTP id 31so42814yxl.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 19:45:11 -0700 (PDT)
In-Reply-To: <CA+UXGK1XAgCxYUoOAP6yQSGhzDB-3p3oDqOoOc_e=rTT3DPx7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all:
Sorry for disturb! when adding a interface to bridge, maybe the bridge
mac address will be changed. the bridge code don't invoke
call_netdevice_notifiers to notify ipv6 code to refresh local link
address. I don't know why. Thanks for your help!

BRs.
