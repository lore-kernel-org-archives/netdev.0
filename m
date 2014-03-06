From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: fix compiler array bounds warning on settings[]
Date: Thu, 06 Mar 2014 16:07:55 -0500 (EST)
Message-ID: <20140306.160755.1956883639088872825.davem@davemloft.net>
References: <20140305003544.23016.55079.stgit@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140305003544.23016.55079.stgit@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 04 Mar 2014 17:35:44 -0700

> With -Werror=array-bounds, gcc v4.7.x warns that in phy_find_valid(), the
> settings[] "array subscript is above array bounds", I think because idx is
> a signed integer and if the caller supplied idx < 0, we pass the guard but
> still reference out of bounds.
> 
> Fix this by making idx unsigned here and elsewhere.
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Applied, thanks.
