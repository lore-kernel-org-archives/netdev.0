From: Jean-Louis Dupond <jean-louis@dupond.be>
Subject: Backport - xen-netback: correctly schedule rate-limited queues
Date: Tue, 11 Jul 2017 11:47:12 +0200
Message-ID: <a8b4e68ed09513baa788427a0abd11f1@dupond.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.dupie.be ([62.210.113.39]:56786 "EHLO apollo.dupie.be"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753081AbdGKJ47 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 05:56:59 -0400
Received: from localhost (localhost [127.0.0.1])
        by apollo.dupie.be (Postfix) with ESMTP id 1DBA733C00FD
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 11:47:13 +0200 (CEST)
Received: from apollo.dupie.be ([127.0.0.1])
        by localhost (apollo.dupie.be [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id LjU4jKfu3LBu for <netdev@vger.kernel.org>;
        Tue, 11 Jul 2017 11:47:12 +0200 (CEST)
Received: from roundcube.dupie.be (localhost [IPv6:::1])
        by apollo.dupie.be (Postfix) with ESMTPA id 4022133C00A1
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 11:47:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Is there a chance the following patch 
(https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=dfa523ae9f2542bee4cddaea37b3be3e157f6e6b) 
can get backported to the current LTS kernels (including 4.9.x)?

The commit message might not be completely showing the impact of this 
issue (which is fixed with the patch).

Without the patch, ksoftirqd goes nuts if you upload on a domU with 
rate-limiting enabled.
This not only causing high cpu load, but sometimes also a complete hang 
of the hypervisor.

As the patch is quite important and trivial, I think it would be good to 
have it backported :)

Thanks
Jean-Louis
