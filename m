From: Kumar Gala <galak@kernel.crashing.org>
Subject: use of bool in exported headers?
Date: Fri, 18 Jul 2008 01:28:02 -0500
Message-ID: <0FE8A686-5F80-4868-8C85-5E82EA9EF2D1@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40568 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695AbYGRG2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 02:28:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What's the rule with regards to use of 'bool' in a header exposed to  
user space apps?

We are getting the following compile error w/iptables because of bool  
in include/linux/netfilter/xt_sctp.h:

In file included from extensions/libip6t_sctp.c:24:
/home/seh/ltib_bsps/head/rootfs//usr/src/linux/include/linux/netfilter/ 
xt_sctp.h:68: error: expected '=', ',', ';', 'asm' or '__attribute__'  
before '__sctp_chunkmap_is_clear'
/home/seh/ltib_bsps/head/rootfs//usr/src/linux/include/linux/netfilter/ 
xt_sctp.h:80: error: expected '=', ',', ';', 'asm' or '__attribute__'  
before '__sctp_chunkmap_is_all_set'
extensions/libip6t_sctp.c: In function 'print_chunks':
extensions/libip6t_sctp.c:427: warning: implicit declaration of  
function '__sctp_chunkmap_is_clear'
extensions/libip6t_sctp.c:432: warning: implicit declaration of  
function '__sctp_chunkmap_is_all_set'
make: *** [extensions/libip6t_sctp_sh.o] Error 1
error: Bad exit status from /home/seh/ltib_bsps/head/tmp/rpm-tmp.23551  
(%build)

- k
