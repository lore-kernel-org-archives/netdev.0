From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Fri, 6 Sep 2013 11:18:21 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B731F@saturn3.aculab.com>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <dev@openvswitch.org>,
	"Andy Zhou" <azhou@nicira.com>,
	"Fengguang Wu" <fengguan.wu@intel.com>,
	"Geert Uytterhoeven" <geert@linux-m68k.org>
To: "Jesse Gross" <jesse@nicira.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53407 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750882Ab3IFKUw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 06:20:52 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10487-03 for <netdev@vger.kernel.org>;
 Fri,  6 Sep 2013 11:20:51 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1378402887-17331-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -} __aligned(__alignof__(long));
> +} __aligned(8); /* 8 byte alignment ensures this can be accessed as a long */

Don't you really want __aligned(MAX(__alignof__(__be64), sizeof (long))) ?

	David
