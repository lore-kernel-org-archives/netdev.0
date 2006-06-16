From: "Wei Dong" <weid@nanjing-fnst.com>
Subject: Question: query for Interface MIB "ifInNUcastPkts "
Date: Fri, 16 Jun 2006 11:36:26 +0800
Message-ID: <00f801c690f6$0cc1f470$6304a8c0@weidong>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="Windows-1252";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <linux.nics@intel.com>, <scott.feldman@intel.com>,
	<jesse.brandeburg@intel.com>, <john.ronciak@intel.com>,
	<auke-jan.h.kok@intel.com>, <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:37774 "EHLO localmail")
	by vger.kernel.org with ESMTP id S1750980AbWFPDsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 23:48:32 -0400
To: "netdev" <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All
    Now I want to test interface MIB(according to RFC1213), and found that 
ifInNUcastPkts doesn't exist in Linux kernel. The kernel maintain a 
structure "net_device_stats", but it just contain a member named "multicast" 
to show how many multicast packets are received, but no member to show how 
many broadcast packets are received. Also, I think ifInNUcastPkts should 
equal to broadcast + multicast. Or there is some other statistic value to 
show "ifInNUcastPkts"?

RFC1213

  INTERNET CONTROL MESSAGE PROTOCOL

  ifInNUcastPkts OBJECT-TYP
      SYNTAX  Counter
      ACCESS  read-only
      STATUS  mandatory
      DESCRIPTION
              "The number of non-unicast (i.e., subnetwork-
              broadcast or subnetwork-multicast) packets
              delivered to a higher-layer protocol."
      ::= { ifEntry 12 }

Any help is grateful and thanks in advance.

Regards
Wei Dong 

