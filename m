From: David Shwatrz <dshwatrz@gmail.com>
Subject: Deleting a network namespace
Date: Thu, 28 Mar 2013 12:43:27 +0200
Message-ID: <CAJJAcodGG6nmRNcF_rC+AUUpCp1MWjU3faGLfRTm9FNc6LT_Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:44661 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab3C1Kn2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 06:43:28 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz10so2824518veb.31
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 03:43:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
When assigning a network interface to a network namespace and
afterwards deleting the namespace, we will not see the network
interface in any other namespace (including the default namespace) anym=
ore:

ip netns add ns1
ip link set=A0eth0 netns ns1
ip netns del ns1

This means that in fact we cannot use this interface again (only after
rebooting)
Am I right on this ?
Is moving an interface back to the default (init) namespace,
when deleting the namespace which contains it, can be considered?

(AFAIK, we don't need to check that this interface is in any other name=
space,
because by definition, a network interface belongs only to one namespac=
e)

DS
