From: Nicholas Thomas <nick@bytemark.co.uk>
Subject: Re: [PATCH] Break up the single NBD lock into one per NBD device
Date: Mon, 04 Feb 2013 15:55:43 +0000
Message-ID: <1359993343.18869.14.camel@eboracum.office.bytemark.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bacon.sh.bytemark.co.uk ([212.110.161.169]:35233 "EHLO
	bacon.sh.bytemark.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756382Ab3BDQTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 11:19:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was wondering if there was any chance of resurrecting this patch: 

http://comments.gmane.org/gmane.linux.network/207233

My use case is a Linux kernel connecting to up to 6,144 NBD devices (in
practice, probably < 1,000 almost all the time) simultaneously - our
current deployment has a userspace implementation of NBD, and I came
across this patch while investigating potential scalability issues.

I've not performed any benchmarks yet, but I assume the issues Jerry Chu
mentions would affect my case too, and the asked-for changes to get it
accepted seemed minimal.

Regards,
-- 
Nick Thomas
Bytemark Computing
