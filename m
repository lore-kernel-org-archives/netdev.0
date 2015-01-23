From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 3/5] bridge: offload bridge port attributes
 to switch asic if feature flag set
Date: Fri, 23 Jan 2015 07:59:55 -0800
Message-ID: <54C26FFB.1050908@cumulusnetworks.com>
References: <1421987606-10884-4-git-send-email-roopa@cumulusnetworks.com> <9B0331B6EBBD0E4684FBFAEDA55776F9189065DD@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35775 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553AbbAWP74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:59:56 -0500
Received: by mail-pd0-f169.google.com with SMTP id g10so6617228pdj.0
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:59:56 -0800 (PST)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F9189065DD@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/15, 4:53 AM, Rosen, Rami wrote:
> Hi,
> There is another Linux Ethernet driver which defines the ndo_bridge_setlink() callback, which is not included in the patch. It is the
> Emulex ServerEngines' 10Gbps NIC (BladeEngine) (drivers/net/ethernet/emulex/benet).
> So once the CONFIG_BE2NET kernel config item is set, running make will emit a compile warning.
>
>
Thanks for catching this and your other comment. will fix them in the 
next version.
