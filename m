From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Sat, 3 Jul 2010 19:55:30 +0100
Message-ID: <2md4g7-3s3.ln1@chipmunk.wormnet.eu>
References: <4C2F7A55.5090700@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:40316 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629Ab0GCTIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jul 2010 15:08:22 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OV84X-0001NP-MK
	for netdev@vger.kernel.org; Sat, 03 Jul 2010 21:08:17 +0200
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 03 Jul 2010 21:08:17 +0200
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 03 Jul 2010 21:08:17 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip Prindeville <philipp_subx@redfish-solutions.com> wrote:
>
> Does anyone else think that setsockopt(IP_TOS) should be a privileged 
> operation, perhaps using CAP_NET_ADMIN, or maybe even adding separate 
> granularity as CAP_NET_TOS?
> 
I really would prefer not having to run telnet and ssh *clients* as 
root. :)

Cheers

-- 
Alexander Clouter
.sigmonster says: Someday your prints will come.
                  		-- Kodak

