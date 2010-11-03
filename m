From: Nolan Leake <nolan@cumulusnetworks.com>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Wed, 03 Nov 2010 16:10:35 -0700
Message-ID: <1288825835.26640.517.camel@voxel>
References: <4CC2DB2C.3060908@xs4all.nl> <1287862760.7499.225.camel@voxel>
	 <4CC40398.6070105@xs4all.nl> <1288142302.26640.7.camel@voxel>
	 <4CC84EAD.7040506@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jim <jim876@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phong.sigbus.net ([64.62.173.8]:48663 "EHLO phong.sigbus.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab0KCXQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 19:16:27 -0400
In-Reply-To: <4CC84EAD.7040506@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-27 at 18:09 +0200, Jim wrote:
> Not exactly, VirtualBox calls it "bridged adapter", it 'bridges' the
> guest machine to the tap0 interface on the host for so called host-only
> networking.
> See eg. http://forums.virtualbox.org/viewtopic.php?f=1&t=165
> 
> And this sequence is now simply failing
>   tunctl -t tap0 -u tuxuser
>   ifconfig tap0 10.0.0.1 up

Jim,

Could you do me a favor and try this sequence:
  tunctl -t tap0 -u tuxuser
  <run virtualbox such that it attaches to tap0>
  ifconfig tap0 10.0.0.1 up

Thanks,
 - nolan
