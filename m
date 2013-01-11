From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 03/15] e1000e: Invalid Image CSUM bit changed for I217
Date: Fri, 11 Jan 2013 10:26:18 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7109@saturn3.aculab.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com> <1357899831-4168-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allan" <bruce.w.allan@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33233 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752977Ab3AKK2P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 05:28:15 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31236-07 for <netdev@vger.kernel.org>;
 Fri, 11 Jan 2013 10:28:11 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1357899831-4168-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	/* Read NVM and check Invalid Image CSUM bit.  If this bit is 0,
> +	 * the checksum needs to be fixed.  This bit is an indication that
> +	 * the NVM was prepared by OEM software and did not calculate
> +	 * the checksum...a likely scenario.

Shouldn't the first line read:
	/* Read NVM and check Valid Image CSUM bit.

	David
