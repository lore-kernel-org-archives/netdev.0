From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 18:02:17 +0300
Message-ID: <200808281802.17867.denys@visp.net.lb>
References: <20080827.201020.17601834.davem@davemloft.net> <21915755.1327801219904892242.JavaMail.root@ouachita> <20080828072218.GI26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joe Malicki <jmalicki@metacarta.com>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754894AbYH1PD6@vger.kernel.org>
In-Reply-To: <20080828072218.GI26610@one.firstfloor.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 August 2008, Andi Kleen wrote:
I hit one more bug, while deleting root class for htb on ifb0 i got tc stuck 
(and all operations related to tc), but there was some fixes for this things 
in net-2.6, so i tried to update git tree.

It seems i cannot test current net-2.6, because it is broken for me 
on USB part (fixed by workaround in init scripts), HPET totally broken in 
net-2.6, but works for latest main git from torvalds tree.
I have to wait when net-2.6 rebased to current torvalds tree, then i will try 
to test.
