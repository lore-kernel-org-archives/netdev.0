From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Support for Intel 82598EB 10-Gigabit AT2 Server Adapter
Date: Fri, 4 Dec 2009 16:36:31 -0800
Message-ID: <9929d2390912041636g39667623nbdff6f55819354e6@mail.gmail.com>
References: <4B1947E5.2020205@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f188.google.com ([209.85.216.188]:36148 "EHLO
	mail-px0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329AbZLEAgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 19:36:25 -0500
Received: by pxi26 with SMTP id 26so797725pxi.21
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2009 16:36:31 -0800 (PST)
In-Reply-To: <4B1947E5.2020205@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2009 at 09:33, Jesper Krogh <jesper@krogh.cc> wrote:
> Hi.
>
> I just got two Intel 82598EB 10-Gigabit AT2 Server Adapter i sort of
> assumed that they "just worked" since I have a AF-adapter (SR-fiber),
> that works flawlessly and it it "just another media" in the other end.
>
> But as of 2.6.31.6 the pci-ids is not registered in modules.pcimap
>
> 82:00.0 0200: 8086:150b (rev 01)
> 84:00.0 Ethernet controller: Intel Corporation 82598EB 10-Gigabit AT2
> Server Adapter (rev 01)
>
> And the adapter does not produce any ethX interfaces for usage when the
> ixgbe drivers is loaded.
>
> Is it as simple as just adding the identifiers to the module-map or is
> there a patch flying around somewhere?
>
> Thanks.
>
> Jesper
>
> --

Support for your NIC was first introduced in 2.6.32 kernel, so your
kernel does not have native support for the NIC.  You can move to
2.6.32 or newer kernel OR simply download the ixgbe driver from
http://e1000.sf.net.  I would suggest downloading the latest version
which is 2.0.44.14 which has support for you NIC.

Support was first introduced in version 2.0.38.2 (which is also on the
sourceforge site), but I would suggest using the latest version.

-- 
Cheers,
Jeff
