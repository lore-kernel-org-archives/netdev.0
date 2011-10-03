From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 00/11] QA check with cppcheck
Date: Mon, 03 Oct 2011 17:21:51 +0200
Message-ID: <4E89D30F.50401@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:59722 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755964Ab1JCPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:31:54 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by rs04.intra2net.com (Postfix) with ESMTP id 8764A22012B
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 4287C2AC57
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 041C32AC53
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I've given iproute2 a good run with the free
cppcheck static code analysis tool.
(http://cppcheck.sourceforge.net/)

Following are eleven patches correcting minor
resource leaks and two real bugs.

Cheers,
Thomas

Thomas Jarosch (11):
  Fix pipe I/O stream descriptor leak in init_service_resolver()
  Fix file descriptor leak on error in rtnl_hash_initialize()
  Fix wrong comparison in cmp_print_eopt()
  Fix wrong sanity check in choke_parse_opt()
  Fix memory leak of lname variable in get_target_name()
  Add missing closedir() call in do_show()
  Fix file descriptor leak on error in iproute_flush_cache()
  Fix file descriptor leak on error in read_viftable()
  Fix file descriptor leak on error in read_mroute_list()
  Fix file descriptor leak in do_tunnels_list()
  Fix file descriptor leak on error in read_igmp()

 ip/ipmaddr.c   |    4 +++-
 ip/ipmroute.c  |    9 ++++++---
 ip/iproute.c   |    1 +
 ip/iptunnel.c  |    3 +++
 ip/iptuntap.c  |    1 +
 lib/rt_names.c |    2 ++
 misc/ss.c      |    1 +
 tc/em_cmp.c    |    2 +-
 tc/m_ipt.c     |    3 +++
 tc/q_choke.c   |    2 +-
 10 files changed, 22 insertions(+), 6 deletions(-)

-- 
1.7.4.4
