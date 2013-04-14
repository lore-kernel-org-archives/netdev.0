From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Could one of you guys take a look at a SCSI FCoE patch for me?
Date: Sun, 14 Apr 2013 13:49:34 -0700
Message-ID: <1365972574.2359.14.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:52471 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753689Ab3DNUtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 16:49:39 -0400
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 411FD8EE0F1
	for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 13:49:39 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VCV3SykJsCrS for <netdev@vger.kernel.org>;
	Sun, 14 Apr 2013 13:49:39 -0700 (PDT)
Received: from [192.168.6.205] (ip-64-134-140-85.public.wayport.net [64.134.140.85])
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 27CFD8EE0A4
	for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 13:49:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's this one:

http://marc.info/?l=linux-scsi&m=136183795505630

It's trying to do some FCoE VLAN discovery protocol, but as I think I
read the patch, it seems to set up a VLAN on the NIC without any
reference to the existing net based VLAN infrastructure, so I had a
couple of questions

     1. Is that right?  I'm not very familiar with the net code so I
        might be misreading
     2. Is that acceptable to net people? 

Thanks,

James
