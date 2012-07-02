From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [PATCH net-next 00/11] default maximal number of RSS queues
 in mq drivers
Date: Mon, 2 Jul 2012 07:55:25 +0300
Message-ID: <4FF129BD.8070904@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
 <4FF0663C.1070306@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	"Divy Le Ray" <divy@chelsio.com>, "Jon Mason" <jdmason@kudzu.us>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	"Ron Mercer" <ron.mercer@qlogic.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Jon Mason" <mason@myri.com>,
	"Andrew Gallatin" <gallatin@myri.com>,
	"Sathya Perla" <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	"Ajit Khaparde" <ajit.khaparde@emulex.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: "Or Gerlitz" <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2342 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab2GBE4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 00:56:50 -0400
In-Reply-To: <4FF0663C.1070306@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I assume this posting is actually v3 of "[RFC net-next (v2) 00/14] default maximal number of RSS queues in mq drivers" see http://marc.info/?l=linux-netdev&m=134062509310404&w=2?
> 


Of course you are correct - the fact that it's based on that RFC is stated
explicitly in PATCH 0 of this series.

> correct? so what has been changed along v0/v1/v2 --> v3?  It would be very helpful to follow
> if you make sure to mark the patches that makes Vn with "PATCH net-next Vn" and specify the changes
> from Vn-1, Vn-2...V1, V0.



Certainly -

Changes from RFC v2:
	- Removed changes for igb, igbxe, and igxbevf drivers.

Changes from RFC v1:
	- Use 'netif_get_num_default_rss_queues()' wrapper function instead
	  of using a hard-coded define value directly.
	- Corrected be2net implementation of this fix.

Cheers,
Yuval
