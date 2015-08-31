From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2 v3] add support for brief output for link and
 addresses
Date: Mon, 31 Aug 2015 16:28:12 -0700
Message-ID: <20150831162812.25cb1d10@urahara>
References: <530e05e07e3d4b199e83f8644e9e18d8@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37507 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752064AbbHaX2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 19:28:07 -0400
In-Reply-To: <530e05e07e3d4b199e83f8644e9e18d8@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2015 17:45:41 +0000
Andy Gospodarek <gospo@cumulusnetworks.com> wrote:

> This adds support for slightly less output than is normally provided by
> 'ip link show' and 'ip addr show'.  This is a bit better when you have a
> host with lots of interfaces.  Sample output:
> 
> $ ip -br link show
> lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
> p2p1             UP             08:00:27:ee:0b:3b <BROADCAST,MULTICAST,UP,LOWER_UP>
> p7p1             UP             08:00:27:9d:62:9f <BROADCAST,MULTICAST,UP,LOWER_UP>
> p8p1             DOWN           08:00:27:dc:d8:ca <NO-CARRIER,BROADCAST,MULTICAST,UP>
> p9p1             UP             08:00:27:76:d9:75 <BROADCAST,MULTICAST,UP,LOWER_UP>
> p7p1.100@p7p1    UP             08:00:27:9d:62:9f <BROADCAST,MULTICAST,UP,LOWER_UP>
> 
> $ ip -br -4 addr show
> lo               UNKNOWN        127.0.0.1/8
> p2p1             UP             192.168.56.2/24
> p7p1             UP             70.0.0.1/24
> p8p1             DOWN           80.0.0.1/24
> p9p1             UP             10.0.5.15/24
> p7p1.100@p7p1    UP             200.0.0.1/24
> 
> $ ip -br -6 addr show
> lo               UNKNOWN        ::1/128
> p2p1             UP             fe80::a00:27ff:feee:b3b/64
> p7p1             UP             7000::1/8 fe80::a00:27ff:fe9d:629f/64
> p8p1             DOWN           8000::1/8
> p9p1             UP             fe80::a00:27ff:fe76:d975/64
> p7p1.100@p7p1    UP             fe80::a00:27ff:fe9d:629f/64
> 
> $ ip -br addr show p7p1
> p7p1             UP             70.0.0.1/24 7000::1/8 fe80::a00:27ff:fe9d:629f/64
> 
> v2: Now with color support!
> v3: Better field width estimation (except netdev names to keep output at a
> decent width) and whitespace fixup.
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

Applied, thanks
