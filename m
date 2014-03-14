From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 02/16] ixgbe: fix spinlock recursion with netpoll
 and busy poll
Date: Fri, 14 Mar 2014 17:53:07 -0400 (EDT)
Message-ID: <20140314.175307.982881304181108101.davem@davemloft.net>
References: <1394790446-31591-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<20140314.145850.706702494963811330.davem@davemloft.net>
	<87618083B2453E4A8714035B62D679924FF2B0DD@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, asharma@fb.com,
	stable@vger.kernel.org, jacob.e.keller@intel.com
To: emil.s.tantilov@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87618083B2453E4A8714035B62D679924FF2B0DD@FMSMSX105.amr.corp.intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Fri, 14 Mar 2014 20:40:25 +0000

> I noticed Eric's patches and this is obviously the better way to
> deal with it, but once the netpoll_rx patches are accepted will they
> make it into previous stable releases? Currently kernels between
> 3.11 and 3.13 (assuming Eric's changes make it into 3.14) will hang
> when netpoll and busy poll are used together.

This is very likely.

And in any event, solving it only in specific drivers is not the way
to go about things.
