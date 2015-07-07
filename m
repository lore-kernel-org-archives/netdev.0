From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 07 Jul 2015 13:51:21 +0200
Message-ID: <1436269881.20057.139.camel@tiscali.nl>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
	 <1436261876.20057.132.camel@tiscali.nl> <20150707101025.GA5003@aepfle.de>
	 <cf30a808b461480d8c399e556ddef513@SIXPR30MB031.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dexuan Cui <decui@microsoft.com>, Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:35335 "EHLO
	lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756600AbbGGLv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:51:26 -0400
In-Reply-To: <cf30a808b461480d8c399e556ddef513@SIXPR30MB031.064d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On di, 2015-07-07 at 10:20 +0000, Dexuan Cui wrote:
> OK, removing the line seems better than 'default n', though both 
> reproduce the same "# CONFIG_HYPERV_SOCK is not set".

Speaking from memory (so chances are I'm forgetting some silly detail)
that is because
    # CONFIG_FOO is not set

will be printed if FOO's dependencies are met and FOO either has a
"prompt" or a default of 'n'.

Hope this helps,


Paul Bolle
