From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: [PATCH 0/6] Changeset of Camellia cipher algorithm.
Date: Wed, 18 Oct 2006 16:15:10 +0900 (JST)
Message-ID: <20061018.161510.796986352.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:52891 "EHLO
	mail2.ics.ntts.co.jp") by vger.kernel.org with ESMTP
	id S1750983AbWJRHUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 03:20:49 -0400
To: linux-crypto@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  This set of the patches enables to use of the Camellia cipher
  algorithm for the ESP encryption.

  Git tree is also available on camellia20061017 branch at:
  git://git.skbuff.net/gitroot/takamiya/camellia20061017

  The following patches are available for the top of davem's net-2.6
  and herbert's cryptodev-2.6 trees.

  Thank you.

HEADLINES
---------

[PATCH 1/6] [CRYPTO] added Kconfig entry for Camellia.
[PATCH 2/6] [CRYPTO] added the code of Camellia cipher algorithm.
[PATCH 3/6] [CRYPTO] added the testing code of Camellia cipher algorithm.
[PATCH 4/6] [IPSEC] added the definition of Camellia cipher algorithm.
[PATCH 5/6] [IPSEC] added the entry of Camellia cipher algorithm to ealg_list[].
[PATCH 6/6] [CRYPTO] added the developer of Camellia cipher algorithm.

DIFFSTAT
--------

 Documentation/crypto/api-intro.txt |    5 
 crypto/Kconfig                     |   15 
 crypto/Makefile                    |    1 
 crypto/camellia.c                  | 1802 ++++++++++++++++++++++++++++++++++++-
 crypto/tcrypt.c                    |   43 
 crypto/tcrypt.h                    |  166 +++
 include/linux/pfkeyv2.h            |    2 
 net/xfrm/xfrm_algo.c               |   18 
 8 files changed, 2045 insertions(+), 7 deletions(-)

CHANGESETS
----------

commit 80a5df8127311212e99bd64103771de19c5908dd
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Tue Oct 17 01:51:40 2006 +0900

    [CRYPTO] added the developer of Camellia cipher algorithm.
    
    This patch adds the developer of Camellia cipher algorithm.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

commit 2253254f5a802c1cc8a5fc367fae911172f28846
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Tue Oct 17 01:47:32 2006 +0900

    [IPSEC] added the entry of Camellia cipher algorithm to ealg_list[].
    
    This patch adds the entry of Camellia cipher algorithm to ealg_list[].
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

commit 1b6712cdb8fd31482d7e7da56e5f602357ec4aa4
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Tue Oct 17 01:45:24 2006 +0900

    [IPSEC] added the definition of Camellia cipher algorithm.
    
    This patch adds the definitions used by pfkeyv2 interface for Camellia cipher
    algorithm.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

commit e86050d8fbd04b1ace9c121ce90799c8210925be
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Tue Oct 17 01:43:14 2006 +0900

    [CRYPTO] added the testing code of Camellia cipher algorithm.
    
    This patch adds the code of Camellia code for testing module.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

commit db41e54cb7081b4cd034378f17b8f8225586e2e2
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Tue Oct 17 01:34:15 2006 +0900

    [CRYPTO] added the code of Camellia cipher algorithm.
    
    This patch adds the main code of Camellia cipher algorithm.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

commit 01b0c3898fdf1cb4da8cdf5577e58328ecb11e4e
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Tue Oct 17 01:31:35 2006 +0900

    [CRYPTO] added Kconfig entry for Camellia.
    
    This patch adds the Kconfig entry for Camellia.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

--
Noriaki TAKAMIYA
