From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: iproute2: missing patches in branch net-next
Date: Thu, 28 May 2015 13:31:08 +0200
Message-ID: <5566FC7C.1000200@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	David Ward <david.ward@ll.mit.edu>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35659 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704AbbE1LbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 07:31:16 -0400
Received: by wicmx19 with SMTP id mx19so142949078wic.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 04:31:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

some patches that were recently included in iproute2 branch net-next are not
visible anymore on kernel.org. It seems that the branch has been overridden
(note the "forced update" when I've fetched it):

$ git fetch
remote: Counting objects: 65, done.
remote: Compressing objects: 100% (65/65), done.
remote: Total 65 (delta 58), reused 0 (delta 0)
Unpacking objects: 100% (65/65), done.
 From git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2
  + aacee2695a90...eb9d6e794b52 net-next   -> origin/net-next  (forced update)
    f043759dd492..c52827e9077f  master     -> origin/master


The following patches are lost:
aacee2695a90 tc: gred: Add support for TCA_GRED_LIMIT attribute
b6ec53e3008a xfrmmonitor: allows to monitor in several netns
449b824ad196 ipmonitor: allows to monitor in several netns
3b0006f8183e ipmonitor: introduce print_headers
0628cddd9d5c libnetlink: introduce rtnl_listen_filter_t
2503247d58c3 man: update ip monitor page
6fc1f8add30b iplink_bond: add support for ad_actor and port_key options
df1c7d9138ea codel: add ce_threshold support to codel & fc_codel
30eb304ecd1d tc: add support for Flower classifier
1a4dda7103bc ss: add support for bytes_acked & bytes_received
908755dc49df iproute2: GENEVE support
f9b004020a89 Merge branch 'master' into net-next
8f42ceaf2491 Update kernels for net-next


Regards,
Nicolas
