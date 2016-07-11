From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6] common library for Chelsio drivers
Date: Mon, 11 Jul 2016 12:50:21 -0700 (PDT)
Message-ID: <20160711.125021.1679165284508297380.davem@davemloft.net>
References: <cover.1467998292.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com
To: varun@chelsio.com
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1467998292.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varun Prakash <varun@chelsio.com>
Date: Fri,  8 Jul 2016 23:03:53 +0530

> Hi,
> 
>  This patch series adds common library module(libcxgb.ko)
> for Chelsio drivers to remove duplicate code.
> 
> This series moves common iSCSI DDP Page Pod manager
> code from cxgb4.ko to libcxgb.ko, earlier this code
> was used by only cxgbit.ko now it is used by
> three Chelsio iSCSI drivers cxgb3i, cxgb4i, cxgbit.
> 
> In future this module will have common connection
> management and hardware specific code that can
> be shared by multiple Chelsio drivers(cxgb4,
> csiostor, iw_cxgb4, cxgb4i, cxgbit).
> 
> Please review.

As currently implemented the user is prompted for the Kconfig symbol
for the library.  That really needs to be hidden from the user and
they should be able to select these drivers without having to know
about this implementation detail at all.
