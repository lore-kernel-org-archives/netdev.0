From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 1/8] e1000e: Minimum packet size must be 17 bytes
Date: Tue, 23 Oct 2012 16:25:49 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B705D@saturn3.aculab.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com> <1350987887-16161-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Tushar Dave" <tushar.n.dave@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53904 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933024Ab2JWPgk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 11:36:40 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02044-06 for <netdev@vger.kernel.org>;
 Tue, 23 Oct 2012 16:36:37 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1350987887-16161-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is a HW requirement. Although a buffer as short as 1 byte is allowed,
> the total length of packet before, padding and CRC insertion, must be at
> least 17 bytes.  So pad all small packets manually up to 17 bytes before
> delivering them to HW.

Where do such very short packets come from?
The shortest one I know of have:
 6 bytes dest-mac
 6 bytes src-mac
 2 bytes length
 3 bytes llc header (eg reflect request).
17 bytes total.

	David
