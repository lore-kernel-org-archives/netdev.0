From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 28 Jul 2006 00:56:57 -0700 (PDT)
Message-ID: <20060728.005657.85412111.davem@davemloft.net>
References: <20060717155224.060020000@hp.com>
	<20060717155823.105055000@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@epoch.ncsc.mil,
	jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16010
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030229AbWG1H5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 03:57:22 -0400
To: paul.moore@hp.com
In-Reply-To: <20060717155823.105055000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Mon, 17 Jul 2006 11:52:27 -0400

> +		cipso_v4_cache[iter].lock = SPIN_LOCK_UNLOCKED;

Please use: "spin_lock_init(&cipso_v4_cache[iter].lock);"

