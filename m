From: =?ISO-8859-1?Q?J=E9r=F4me_Poulin?= <jeromepoulin@gmail.com>
Subject: IFB and iptables
Date: Wed, 25 May 2011 18:21:39 -0400
Message-ID: <BANLkTimzL0_w=+CvbFNxNS=wAOZ61CrrdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:37041 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab1EYWV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:21:56 -0400
Received: by gyd10 with SMTP id 10so53774gyd.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 15:21:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to convert my IMQ based script to use the IFB device instead.
Things appear to work quite right however the u32 classifier isn't
aware of any connection tracking and I was wondering if it is at all
possible to use match from iptables like layer7 when you use the IFB
device?

And my need for the IFB device / IMQ is because I want to classify my
IPv6 traffic which is in an IPv4 SIT tunnel and mix the content of the
SIT tunnel to eth0 minus protocol 41.

Thanks.
