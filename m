From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v2 0/3] extend set/get netlink for embedded
Date: Tue, 13 Nov 2012 09:16:25 -0800
Message-ID: <50A28069.1070903@intel.com>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab> <6AE768456CEC4B4A9B2248CB6B87EB3E1BC95245@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"krkumar2@in.ibm.com" <krkumar2@in.ibm.com>,
	"samudrala@us.ibm.com" <samudrala@us.ibm.com>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5086 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932236Ab2KMRQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:16:36 -0500
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BC95245@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This series looks fine from bnx2x point of view.
> The dynamic change from VEB to VEPA will require a firmware change,
> so we might arrive a little late for the party.
> Ariel
>

In the meantime you could enable just the get routines
so the upper layer could learn how your SR-IOV switching
is being done or not done.

My basic expectation is hardware defaults to VEB but
not sure if that is true in all cases.

.John
