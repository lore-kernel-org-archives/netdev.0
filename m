From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 7 Jul 2015 12:58:37 +0200
Message-ID: <20150707105836.GA19818@aepfle.de>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
 <1436261876.20057.132.camel@tiscali.nl>
 <20150707101025.GA5003@aepfle.de>
 <cf30a808b461480d8c399e556ddef513@SIXPR30MB031.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Paul Bolle <pebolle@tiscali.nl>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.163]:32631 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756808AbbGGK6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:58:39 -0400
Content-Disposition: inline
In-Reply-To: <cf30a808b461480d8c399e556ddef513@SIXPR30MB031.064d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, Dexuan Cui wrote:

> OK, removing the line seems better than 'default n', though both reproduce
> the same "# CONFIG_HYPERV_SOCK is not set".

Perhaps "default VMBUS" (or whatever syntax is needed) may be the way to
enable it conditionally.

Olaf
