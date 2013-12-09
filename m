From: Alexander Aring <alex.aring@gmail.com>
Subject: ifconfig doesn't show assignment ip-addresses
Date: Mon, 9 Dec 2013 16:32:39 +0100
Message-ID: <20131209153238.GA10317@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33464 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467Ab3LIPcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 10:32:46 -0500
Received: by mail-wi0-f174.google.com with SMTP id z2so3948504wiv.13
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 07:32:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On current net-next with a lowpan interface created with:

ip link add link wpan0 name lowpan0 type lowpan

I don't see any ipv6 addresses in ifconfig anymore. The addresses exist,
because I can ping my device.

I bisect this issue on commit:
479840ffdbe4242e8a25349218c8e0859223aa35

Does anybody know what's going up there?

- Alex
