From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-2.6 PATCH 2/3] ixgbe: In SR-IOV mode insert delay before
 bring the adapter up
Date: Fri, 26 Mar 2010 12:45:40 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755A3718698@orsmsx508.amr.corp.intel.com>
References: <20100324193515.6078.27035.stgit@localhost.localdomain>
	<20100324193608.6078.61157.stgit@localhost.localdomain>
 <20100326.115753.160228163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57739 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab0CZTpn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 15:45:43 -0400
In-Reply-To: <20100326.115753.160228163.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, March 26, 2010 11:58 AM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
>Subject: Re: [net-2.6 PATCH 2/3] ixgbe: In SR-IOV mode insert delay
>before bring the adapter up
>
>
>
> My point is that this behavior is basically extremely undesirable.

No argument from me there.  We've been discussing design changes to maintain a little more state in the driver so that we wouldn't have to reset the entire device every time someone makes a minor configuration change.  However, I have no target date for that.  I agree that at some point in systems with a large number of interfaces this behavior becomes untenable.

- Greg

