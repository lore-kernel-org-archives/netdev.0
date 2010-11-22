From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH 00/00] Remove deprecated items from Makefiles
Date: Sun, 21 Nov 2010 20:03:11 -0500
Message-ID: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Cc: marcel@holtmann.org, padovan@profusion.mobi,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	sjur.brandeland@stericsson.com, socketcan@hartkopp.net,
	urs.thuermann@volkswagen.de, socketcan-core@lists.berlios.de,
	sage@newdream.net, ceph-devel@vger.kernel.org,
	wang840925@gmail.com, jlayton@redhat.com, kaber@trash.net,
	pekkas@netcore.fi, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I changed Makefiles to use <modules>-y instead of <modules>-objs because -objs
is deprecated and not even mentioned in Documentation/kbuild/makefiles.txt.

Also, remove some if-conditional statments because I used the ccflags-$ flag 
instead of EXTRA_CFLAGS because EXTRA_CFLAGS.

regards,

Tracey Dent

