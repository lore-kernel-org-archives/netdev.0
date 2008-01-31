From: Andi Kleen <ak@suse.de>
Subject: hard hang through qdisc
Date: Thu, 31 Jan 2008 13:21:00 +0100
Message-ID: <200801311321.01015.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:51732 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761334AbYAaMVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:21:05 -0500
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 64DC027A20
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 13:21:04 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



I just managed to hang a 2.6.24 (+ some non network patches) kernel 
with the following (non sensical) command

tc qdisc add dev eth0 root tbf rate 1000 burst 10 limit 100

No oops or anything just hangs. While I understand root can
do bad things just hanging like this seems a little extreme.

-Andi
