From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Check return from pci_find_ext_capability() in
 atl1c_reset_pcie()
Date: Thu, 19 Dec 2013 19:15:09 -0500 (EST)
Message-ID: <20131219.191509.632527739089683539.davem@davemloft.net>
References: <1387475949-30452-1-git-send-email-betty.dall@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: betty.dall@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387475949-30452-1-git-send-email-betty.dall@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Betty Dall <betty.dall@hp.com>
Date: Thu, 19 Dec 2013 10:59:09 -0700

> The function atl1c_reset_pcie() does not check the return from
> pci_find_ext_cabability() where it is getting the postion of the
> PCI_EXT_CAP_ID_ERR. It is possible for the return to be 0.
> 
> Signed-off-by: Betty Dall <betty.dall@hp.com>

Applied, thank you.
