From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite
 memory
Date: Wed, 08 Jul 2009 10:45:39 -0700 (PDT)
Message-ID: <20090708.104539.226485646.davem@davemloft.net>
References: <4A53CD39.7080407@gmail.com>
	<20090707.191424.167842005.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751847AbZGHRpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 13:45:36 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Wed, 8 Jul 2009 11:02:22 -0600

> Still seeing traces during the test even with this patch applied:
> 
> [ 1089.430093] ------------[ cut here ]------------
> [ 1089.435667] WARNING: at include/net/sock.h:423 udp_lib_unhash+0x73/0xa0()
> [ 1089.435670] Hardware name: S5520HC

Ok I'll back this out for now, needs more investigation
obviously.
