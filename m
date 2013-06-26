From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net-next 07/10] igb: Added rcu_lock to avoid race
Date: Wed, 26 Jun 2013 12:58:42 -0700
Message-ID: <1372276722.3301.209.camel@edumazet-glaptop>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1372244122-17664-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1372245628.3301.172.camel@edumazet-glaptop>
	 <CFEEE81102D91947B9CC368106979EBA4388266B@ORSMSX105.amr.corp.intel.com>
	 <1372276361.3301.208.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Abodunrin, Akeem G" <akeem.g.abodunrin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:51817 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab3FZT63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 15:58:29 -0400
Received: by mail-ea0-f173.google.com with SMTP id g15so7813452eak.18
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 12:58:28 -0700 (PDT)
In-Reply-To: <1372276361.3301.208.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 12:52 -0700, Eric Dumazet wrote:

> 
> You did not add call_rcu() in this patch, therefore you do not need
> this.
> 
> I am extra careful of people adding useless rcu synchronization just
> because they feel better :)

BTW the rcu_barrier() in ixgbe is no longer needed as well, now it uses
kfree_rcu()
