From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 2/3] r8169: Use dev_kfree_skb in Tx cleanup path
Date: Fri, 01 May 2015 14:15:42 +0200
Message-ID: <55436E6E.5050609@gmx.de>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22> <20150430205824.1512.35158.stgit@ahduyck-vm-fedora22> <20150501093420.GA11669@electric-eye.fr.zoreil.com> <55436C4B.7090509@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Dept-HSGLinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	davem@davemloft.net, ebiederm@xmission.com
To: Francois Romieu <romieu@fr.zoreil.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:52878 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753518AbbEAMQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 08:16:18 -0400
In-Reply-To: <55436C4B.7090509@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.05.2015 14:06, Lino Sanfilippo wrote:

> which did just the opposite: replace dev_kfree() with dev_kfree_any()
> for that reason. See
> 

Um, this should of course be dev_kfree_skb() and dev_kfree_skb_any().

Lino
