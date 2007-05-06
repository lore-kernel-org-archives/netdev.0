From: "Emil S Tantilov" <emils.tantilov@gmail.com>
Subject: Re: eth1 became eth2, but dmesg still says eth1
Date: Sun, 6 May 2007 09:19:40 -0700
Message-ID: <bde4e1140705060919l46f40a1ajf0d38426b02c5d7d@mail.gmail.com>
References: <20070506053824.GC6222@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Ryan Richter" <ryan@tau.solarneutrino.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:8903 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754927AbXEFQTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 12:19:40 -0400
Received: by an-out-0708.google.com with SMTP id d18so82984and
        for <netdev@vger.kernel.org>; Sun, 06 May 2007 09:19:40 -0700 (PDT)
In-Reply-To: <20070506053824.GC6222@tau.solarneutrino.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> However the bond0 interface failed to come up, complaining that there
> was no such interface as eth1.  I checked /proc/net/dev, and it listed
> eth0 and _eth2_.  I changed the bonding configuration to use eth0 and
> eth2 and it's working fine now.

Check your udev rules. This is usually what is causing interface to
come up differently than what you would expect.

Emil
