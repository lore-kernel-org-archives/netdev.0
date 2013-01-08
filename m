From: nitin padalia <padalia.nitin@gmail.com>
Subject: Fwd: setsockopt() doesn't throw error while setting IP_TTL set to 0
 on RHEL6
Date: Tue, 8 Jan 2013 11:48:35 +0530
Message-ID: <CADxGeP62ebaC4HHz-mqsBq_n6-8DzbX8YoMe-D9N8mV-P5STcg@mail.gmail.com>
References: <CADxGeP6X09uRmaV2y6ugdforbjyAvqnq6_D_=OuAP1+6q7EONA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46657 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab3AHGZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 01:25:27 -0500
Received: by mail-we0-f174.google.com with SMTP id x10so35155wey.19
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 22:25:26 -0800 (PST)
In-Reply-To: <CADxGeP6X09uRmaV2y6ugdforbjyAvqnq6_D_=OuAP1+6q7EONA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------- Forwarded message ----------
From: nitin padalia <padalia.nitin@gmail.com>
Date: Tue, Jan 8, 2013 at 11:46 AM
Subject: setsockopt() doesn't throw error while setting IP_TTL set to 0 on RHEL6
To: majordomo@vger.kernel.org


While setting IP_TTL's optval to 0 using setsockopt() then function
doesn't throw any error anymore and sets the TTL value to 0. However
 in previous release it used to throw error.

This causes problem on the behavior of client application. I've tested
with ping utility and I could able to set TTL value to 0.


Best Regards,
Nitin Padalia
