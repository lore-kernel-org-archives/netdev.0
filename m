From: Andrew Qu <andrew.qu@mediatek.com>
Subject: VxLAN support question
Date: Mon, 10 Aug 2015 23:47:56 +0000
Message-ID: <EA360A7AB9D90D4B9E9173B6D27C371EE3F7B8CA@MTKMBS61N1.mediatek.inc>
References: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
 <20150807.114645.2108374064397756373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"ast@plumgrid.com" <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([69.46.227.142]:49685 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853AbbHJXyg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 19:54:36 -0400
In-Reply-To: <20150807.114645.2108374064397756373.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi VxLAN experts,

In user space, we are developing a CLI as the  following:

Interface tunnel 100
   Mode vxlan 
   Remote ip ipv4 19.1.1.1
   Local ip ipv4 20.1.1.1
   Vni 1-1000  <====

With Kernel 3.12.37,  we can't support above configurations in kernel. (OR PLEASE
Correct me if I am wrong)

Noticing VxLAN supports has been actively worked on, hoping most
Recent kernel allow functionality above is supported now.

Pretty much what I want is that  kernel will have about 1K interfaces (something like Tunnel100.1-tunnel100.1000
To be created and attached to 1K bridge domains on which each VNI is associated with given
VNI to bridge-domain will be assigned using other CLIs)

Thanks,

Andrew


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
