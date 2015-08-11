From: Andrew Qu <andrew.qu@mediatek.com>
Subject: RE: VxLAN support question
Date: Tue, 11 Aug 2015 17:58:14 +0000
Message-ID: <EA360A7AB9D90D4B9E9173B6D27C371EE3F7BC1C@MTKMBS61N1.mediatek.inc>
References: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
 <20150807.114645.2108374064397756373.davem@davemloft.net>
 <EA360A7AB9D90D4B9E9173B6D27C371EE3F7B8CA@MTKMBS61N1.mediatek.inc>
 <55C98A18.9020900@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([69.46.227.141]:42803 "EHLO
	mailgw01.mediatek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbHKSEA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:04:00 -0400
In-Reply-To: <55C98A18.9020900@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

I support using mcast group for all VNIs in control plane/data plane.
But in case there is no mcast routing enabled, I need to support
P2P vxlan underlay, hence use of the configuration I showed.

Thanks for the confirmation.

By the way, any informational doc I can read to know about the metadata mode of vxlan?

Andrew



======== please ignore my company added confidentiality notice on this thread =====================


-----Original Message-----
From: Alexei Starovoitov [mailto:ast@plumgrid.com] 
Sent: Monday, August 10, 2015 10:37 PM
To: Andrew Qu; David Miller
Cc: tgraf@suug.ch; jesse@nicira.com; pshelar@nicira.com; netdev@vger.kernel.org
Subject: Re: VxLAN support question

On 8/10/15 4:47 PM, Andrew Qu wrote:
>
> Pretty much what I want is that  kernel will have about 1K interfaces 
> (something like Tunnel100.1-tunnel100.1000 To be created and attached 
> to 1K bridge domains on which each VNI is associated with given VNI to 
> bridge-domain will be assigned using other CLIs)

creating 1k vxlan devices is doable, but you probably want to take a look at recently added metadata mode of vxlan.
Also sounds like for each vni you'd need a different multicast group?
What fabric going to support that?

> ************* Email Confidentiality Notice ********************

please avoid such banners.

************* Email Confidentiality Notice ********************
The information contained in this e-mail message (including any 
attachments) may be confidential, proprietary, privileged, or otherwise
exempt from disclosure under applicable laws. It is intended to be 
conveyed only to the designated recipient(s). Any use, dissemination, 
distribution, printing, retaining or copying of this e-mail (including its 
attachments) by unintended recipient(s) is strictly prohibited and may 
be unlawful. If you are not an intended recipient of this e-mail, or believe 
that you have received this e-mail in error, please notify the sender 
immediately (by replying to this e-mail), delete any and all copies of 
this e-mail (including any attachments) from your system, and do not
disclose the content of this e-mail to any other person. Thank you!
