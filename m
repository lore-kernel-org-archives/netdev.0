From: Robert Schulze <rob@net-pr.de>
Subject: Re: [PATCH] airo: make debug-like messages printed by	airo_print_dbg()
Date: Sun, 09 Jul 2006 19:14:28 +0200
Message-ID: <44B13974.9090604@net-pr.de>
References: <44AFD651.8030801@net-pr.de> <1152455044.2519.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p15181122.pureserver.info ([212.227.60.11]:64683 "EHLO
	p15181122.pureserver.info") by vger.kernel.org with ESMTP
	id S964867AbWGIRJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 13:09:08 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1152455044.2519.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Dan Williams schrieb:
 > This message will only happen if the card hangs up and stops responding
 > to commands anyway, so we don't necessarily care about making the
 > message decipherable to anyone other than developers.

Well, I get this message each time I insert my Cisco Aironet 350 PCMCIA card, which works obviously fine.
On card removal, I get:

airo(eth1): cmd= 21

airo(eth1): status= ffff

airo(eth1): Rsp0= ffff

airo(eth1): Rsp1= ffff

airo(eth1): Rsp2= ffff

four(!) times.

Besides, the messages can be read by issuing dmesg even after the patch, so no information gets lost.


with kind regards,

Robert Schulze
