From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: Cleanup handling of VLAN_HLEN
 as a part of max frame size
Date: Thu, 09 Apr 2015 08:51:18 -0700
Message-ID: <55269FF6.4090003@gmail.com>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org> <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22> <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org> <5525B2AE.80301@gmail.com> <alpine.NEB.2.11.1504081602260.3388@chris.i8u.org> <5525B62A.1050601@gmail.com> <alpine.NEB.2.11.1504081705350.3388@chris.i8u.org> <alpine.NEB.2.11.1504081714400.3388@chris.i8u.org> <5525D389.3010700@gmail.com> <BD4006F19E8FC247A4760EC0EE12CCDF468ACD40@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mike@cchtml.com" <mike@cchtml.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Ertman, David M" <david.m.ertman@intel.com>,
	"Lubetkin, YanirX" <yanirx.lubetkin@intel.com>
To: "Templeman, Chaim" <chaim.templeman@intel.com>,
	Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34172 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755599AbbDIPvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:51:20 -0400
Received: by pdbqa5 with SMTP id qa5so99922183pdb.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 08:51:20 -0700 (PDT)
In-Reply-To: <BD4006F19E8FC247A4760EC0EE12CCDF468ACD40@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 11:17 PM, Templeman, Chaim wrote:
> We will look into this with the HW architect and get back to you on what the HW limitations actually are on this issue.

Chaim, thanks for looking into this.  The key piece that would be useful
to know is if the 9018 should really be 9022 if you account for both
VLAN header and CRC.  Based on the documentation for the Windows driver
that seems to be the case as they support an MTU of 9014 excluding the 8
bytes for CRC and VLAN header.

- Alex
