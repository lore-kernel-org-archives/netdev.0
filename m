From: Joe Eykholt <jre@nuovasystems.com>
Subject: Re: [PATCH 0/3] bonding: allow L2 receive on slaves
Date: Wed, 07 May 2008 23:12:52 -0700
Message-ID: <482299E4.80802@nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:45735 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753628AbYEHGM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 02:12:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay and Jeff,

I'm new on this alias and the patch set I submitted on 5/4 is my first 
for Linux.

I'm not sure I'm doing this right, but I have seen no comments at all 
about the
changes.  Would you make some suggestions as to how I should proceed? 

I'm willing to rewrite the patch as necessary to get the problem solved. 
If there's an issue on the basic idea, please let me know what it is.

I saw another recent patch that would allow LLDP to be delivered
on the bond even if it arrived on an inactive slave.  If it would
be more acceptable, we could add FCoE and FIP (being discussed in T11)
as two other exceptions.  This would be low impact as well, but not
as nice for the protocols, IMHO.   For example, if an L2 protocol had
a packet_type using a slave before the bond was created, it would
be cut off from any traffic.

Again, any suggestions would be appreciated. 
I know everyone is busy, so thanks for your time.

    Cheers,
    Joe Eykholt
