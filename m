From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 10/11] e1000e: fix sparse warnings with -D__CHECK_ENDIAN__
Date: Tue, 7 Feb 2012 12:58:35 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E5C@saturn3.aculab.com>
References: <1328618038-5008-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allan" <bruce.w.allan@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57707 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756102Ab2BGM7A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 07:59:00 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17881-03 for <netdev@vger.kernel.org>;
 Tue,  7 Feb 2012 12:58:57 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1328618038-5008-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>  	for (i = 0; i < last_word - first_word + 1; i++)
> -		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
> +		cpu_to_le16s(&eeprom_buff[i]);

The old version is likely to generate much better code.

	David
