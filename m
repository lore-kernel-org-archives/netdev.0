From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Thu, 16 May 2013 00:00:10 -0400
Message-ID: <CAJZOPZLjdALP4jkLo6p787jaPx=dkKj7+AmCr9+mgJN3z_xBxQ@mail.gmail.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
	<1368498506-25857-7-git-send-email-yinghai@kernel.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CFB0E4E@MTLDAG01.mtl.com>
	<CAE9FiQVn4F+dTrQn0xsg-6QY9+HwbnJR=1CrjdoZkmF_LMrgpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yan Burman <yanb@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:47656 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab3EPEAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 00:00:12 -0400
In-Reply-To: <CAE9FiQVn4F+dTrQn0xsg-6QY9+HwbnJR=1CrjdoZkmF_LMrgpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 14, 2013 at 11:43 AM, Yinghai Lu <yinghai@kernel.org> wrote:

> BTW, do you have any plan to make mlx4 support sriov_configure via sysfs?

yes we do, we're waiting for a firmware change that will allow for
such a patch to get working.

Please note that this whole lockdep warning was identified as false
positive by Tejun http://www.spinics.net/lists/linux-pci/msg21568.html

Or.
