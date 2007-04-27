From: "Nic Gyrovague" <nic.gyrovague@gmail.com>
Subject: how to determine IP address within network device driver?
Date: Fri, 27 Apr 2007 08:35:08 +0200
Message-ID: <e14fe6280704262335l754fcc56s115e43a220ed35c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:62802 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401AbXD0GfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 02:35:10 -0400
Received: by nz-out-0506.google.com with SMTP id o1so1038809nzf
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 23:35:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(apologies for the repost, I thought people may have missed this
question since it was not phrased as such)

I have a hw network device that can benefit from knowing what its
associated IP addresses (if any) are... Is there a "correct" way to
determine the IP address(es) from within the driver code?

Its obviously possible to snoop into ARP
and IP traffic to try to "guess", but this is not always 100% reliable
(e.g. with bridging) and also only gives you the IP address once packets
have started flowing...

In other words, if userspace sets/changes or adds (e.g. IP alias) an
IP address to the device (e.g. "ifconfig eth0  192.168.1.5"), I'd like
to somehow be informed of that within my driver, or failing that, be
able to somehow poll a kernel structure or API to determine said
information...

-- 
gyrovague
