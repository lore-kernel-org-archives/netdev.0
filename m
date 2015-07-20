From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: patch for udp_sendmsg
Date: Mon, 20 Jul 2015 10:10:53 +0800
Message-ID: <55AC58AD.1010703@cn.fujitsu.com>
References: <55ABB67E.8040100@126.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Zhenwei Pi <p_ace@126.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:58829 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755083AbbGTCNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 22:13:49 -0400
In-Reply-To: <55ABB67E.8040100@126.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

Read "Documentation/SubmittingPatches" before sending out the
first patch.

On 07/19/2015 10:38 PM, Zhenwei Pi wrote:
> Dear Sirs,
> 
> Commit : the max length of udp msg is (0xFFFF - sizeof(struct udphdr) - sizeof(struct iphdr). return -EMSGSIZE in udp_sendmsg.
> Patch : as the attached file
> 
> ____________________________________________________________
> | IP header |  UDP header | udp data ........                             |
> |___________|______________|_________________________________|
> |--> Total Length : 0xffff                                                       <--|
> 
> 
> If length of "data" is between (0xFFFF - sizeof(struct udphdr) - sizeof(struct iphdr) and 0xFFFF, sendto will fail because of ip_make_skb.
> Should kernel return -EMSGSIZE as soon as possible ?
> 
> 
