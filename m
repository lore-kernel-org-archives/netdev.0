From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next 02/11] e1000e: cleanup: rename e1000e_setup_link() and call as function pointer
Date: Mon, 27 Feb 2012 10:25:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7C@saturn3.aculab.com>
References: <1330149000-25907-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allan" <bruce.w.allan@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60716 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752811Ab2B0K0Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 05:26:24 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15886-05 for <netdev@vger.kernel.org>;
 Mon, 27 Feb 2012 10:26:20 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1330149000-25907-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Rename e1000e_setup_link() to e1000e_setup_link_generic() to signify
the
> function is used for more than one MAC-family type.  The 82571-family
has
> a custom setup_link function which also calls the generic function.
The
> ich8lan-family has a custom function which should just be called via
the
> function pointer.  The 80003es2lan-family just uses the generic
function.

Wouldn't it be better to add a suffix to the family-specific
functions instead of adding a lot of unnecessary churn?

	David
