From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 00/16] Labeled networking patches for 2.6.28
Date: Wed, 1 Oct 2008 11:34:24 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011128240.5277@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916124722.17132.38741.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found some sparse warnings -- the last couple at least may need 
attention:

$ make C=2 CF="-D__cold__=" SUBDIRS=net/netlabel

  CHECK   net/netlabel/netlabel_user.c
  CC      net/netlabel/netlabel_user.o
  CHECK   net/netlabel/netlabel_kapi.c
  CC      net/netlabel/netlabel_kapi.o
  CHECK   net/netlabel/netlabel_domainhash.c
net/netlabel/netlabel_domainhash.c:143:3: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_domainhash.c:143:3: originally declared here
net/netlabel/netlabel_domainhash.c:143:3: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_domainhash.c:143:3: originally declared here
net/netlabel/netlabel_domainhash.c:635:3: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_domainhash.c:635:3: originally declared here
net/netlabel/netlabel_domainhash.c:635:3: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_domainhash.c:635:3: originally declared here
  CC      net/netlabel/netlabel_domainhash.o
  CHECK   net/netlabel/netlabel_addrlist.c
  CC      net/netlabel/netlabel_addrlist.o
  CHECK   net/netlabel/netlabel_mgmt.c
  CC      net/netlabel/netlabel_mgmt.o
  CHECK   net/netlabel/netlabel_unlabeled.c
net/netlabel/netlabel_unlabeled.c:265:2: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_unlabeled.c:265:2: originally declared here
net/netlabel/netlabel_unlabeled.c:265:2: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_unlabeled.c:265:2: originally declared here
net/netlabel/netlabel_unlabeled.c:1282:3: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_unlabeled.c:1282:3: originally declared here
net/netlabel/netlabel_unlabeled.c:1282:3: warning: symbol '_________p1' shadows an earlier one
net/netlabel/netlabel_unlabeled.c:1282:3: originally declared here
  CC      net/netlabel/netlabel_unlabeled.o
  CHECK   net/netlabel/netlabel_cipso_v4.c
net/netlabel/netlabel_cipso_v4.c:686:21: warning: incorrect type in argument 1 (different signedness)
net/netlabel/netlabel_cipso_v4.c:686:21:    expected unsigned int 
[usertype] *skip_cnt
net/netlabel/netlabel_cipso_v4.c:686:21:    got int *<noident>
net/netlabel/netlabel_cipso_v4.c:622:2: warning: context imbalance in 'netlbl_cipsov4_list' - different lock contexts for basic block
  CC      net/netlabel/netlabel_cipso_v4.o
  LD      net/netlabel/built-in.o
  Building modules, stage 2.
  MODPOST 0 modules


-- 
James Morris
<jmorris@namei.org>
