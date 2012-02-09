From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 4/7] e1000e: use true/false for bool autoneg_false
Date: Thu, 9 Feb 2012 13:15:37 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>
References: <1328783282-17760-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allan" <bruce.w.allan@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37615 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754136Ab2BINQI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 08:16:08 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28675-06 for <netdev@vger.kernel.org>;
 Thu,  9 Feb 2012 13:16:01 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1328783282-17760-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> -		if (mac->autoneg_failed == 0) {
> -			mac->autoneg_failed = 1;
> +		if (mac->autoneg_failed == false) {
> +			mac->autoneg_failed = true;

Don't check for equality with true/false.
Booleans also work better if you avoid double-negatives.

	David
