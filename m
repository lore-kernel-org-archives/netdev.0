From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: compat-wireless release based on v3.4-rc1
Date: Wed, 4 Apr 2012 05:32:10 -0700
Message-ID: <CAB=NE6XO3+36C3yxd+Tw-zBd86Fd3=xOgtto86+SsG4kw1LLYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org,
	lf_driver_backport@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62896 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106Ab2DDMcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 08:32:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3.4-rc1 is out and we now have a respective backport of that release
[0] for ethernet, bluetooth and wireless. This release has been
compile tested with ckmake against all supported kernel versions,
v2.6.24 - v3.3 and verified to have compiled on each one of them.
Moving forward every single compat-wireless release will have been
tested with ckmake to ensure that it builds on all supported kernels.
For details of the changes involved in this release check the
ChangeLog-3.4-rc1 [1], for details of the build you can check the
ckmake-3.4-rc1-2.log.bz2 [2].

compat-wireless code metrics

    829306 - Total upstream lines of code being pulled
      2748 - backport code changes
      2333 - backport code additions
       415 - backport code deletions
      9551 - backport from compat module
     12299 - total backport code
    1.4830 - % of code consists of backport work

Base tree: linux-stable.git
Base tree version: v3.4-rc1
compat-wireless release: compat-wireless-v3.4-rc1-2
Code metrics archive: http://bit.ly/H6BTF7

mcgrof@flash ~/compat-wireless-3.4-rc1-2 $ time ckmake

Trying kernel                     3.2.2-030202-generic  [OK]
Trying kernel                    3.1.10-030110-generic  [OK]
Trying kernel                    3.0.18-030018-generic  [OK]
Trying kernel                  2.6.39-02063904-generic  [OK]
Trying kernel                  2.6.38-02063808-generic  [OK]
Trying kernel                  2.6.37-02063706-generic  [OK]
Trying kernel                  2.6.36-02063604-generic  [OK]
Trying kernel                  2.6.35-02063512-generic  [OK]
Trying kernel                  2.6.34-02063410-generic  [OK]
Trying kernel                  2.6.33-02063305-generic  [OK]
Trying kernel                  2.6.32-02063255-generic  [OK]
Trying kernel                  2.6.31-02063113-generic  [OK]
Trying kernel                  2.6.30-02063010-generic  [OK]
Trying kernel                  2.6.29-02062906-generic  [OK]
Trying kernel                  2.6.28-02062810-generic  [OK]
Trying kernel                    2.6.27-020627-generic  [OK]
Trying kernel                    2.6.26-020626-generic  [OK]
Trying kernel                    2.6.25-020625-generic  [OK]
Trying kernel                    2.6.24-020624-generic  [OK]

real    78m2.934s
user    234m29.807s
sys     21m29.209s

[0] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.4/compat-wireless-3.4-rc1-2.tar.bz2
[1] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.4/ChangeLog-3.4-rc1
[2] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.4/ckmake-3.4-rc1-2.log.bz2

  Luis
