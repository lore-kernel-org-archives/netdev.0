From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Inquiry About How to Make Reliable Wireless Injection Using MAC80211
Date: Tue, 04 Jun 2013 00:17:52 +0200
Message-ID: <51AD1610.8010200@redhat.com>
References: <51ACF5CA.2060709@iol.unh.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Craig Chabot <cly34@iol.unh.edu>
To: Jackson Corson <jcorson@iol.unh.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758944Ab3FCWR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 18:17:59 -0400
In-Reply-To: <51ACF5CA.2060709@iol.unh.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Haven't heard about Lorcon2, but basically PF_PACKET can inject raw 802.11
packets on monitor devices. E.g. I've seen some scripts generating trafgen
configs to send out beacon frames advertising an arbitrary fake SSID.
