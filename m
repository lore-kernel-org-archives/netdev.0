From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: VxLAN support question
Date: Mon, 10 Aug 2015 22:37:28 -0700
Message-ID: <55C98A18.9020900@plumgrid.com>
References: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
 <20150807.114645.2108374064397756373.davem@davemloft.net>
 <EA360A7AB9D90D4B9E9173B6D27C371EE3F7B8CA@MTKMBS61N1.mediatek.inc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Qu <andrew.qu@mediatek.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33038 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbbHKFhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 01:37:31 -0400
Received: by pabyb7 with SMTP id yb7so122269631pab.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 22:37:30 -0700 (PDT)
In-Reply-To: <EA360A7AB9D90D4B9E9173B6D27C371EE3F7B8CA@MTKMBS61N1.mediatek.inc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/15 4:47 PM, Andrew Qu wrote:
>
> Pretty much what I want is that  kernel will have about 1K interfaces (something like Tunnel100.1-tunnel100.1000
> To be created and attached to 1K bridge domains on which each VNI is associated with given
> VNI to bridge-domain will be assigned using other CLIs)

creating 1k vxlan devices is doable, but you probably want to take
a look at recently added metadata mode of vxlan.
Also sounds like for each vni you'd need a different multicast group?
What fabric going to support that?

> ************* Email Confidentiality Notice ********************

please avoid such banners.
