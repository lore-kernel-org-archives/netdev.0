From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: 2.3.31++: Badness at kernel/softirq.c:143 due to new session
	leader connector
Date: Tue, 29 Sep 2009 15:24:15 +0200
Message-ID: <20090929132415.GB4538@redhat.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <200909291226.28548.borntraeger@de.ibm.com> <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org
To: Evgeny Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351AbZI2N2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 09:28:40 -0400
Content-Disposition: inline
In-Reply-To: <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29, Evgeny Polyakov wrote:
>
> I'm yet do download the latest git to check this particular patch, but
> I suppose it is possible to copy data under the lock into temporary
> buffer and then send it using existing infrastructure instead of
> calling it under the tasklist lock.

Afaics, we can just shift proc_sid_connector() from __set_special_pids()
to sys_setsid().

Oleg.

