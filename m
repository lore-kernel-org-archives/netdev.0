From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 29/29] fm10k: Add support for PTP
Date: Mon, 22 Sep 2014 11:03:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174973B0@AcuExch.aculab.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
 <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com>
 <20140919173504.GA4136@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: 'Richard Cochran' <richardcochran@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49544 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752908AbaIVLEc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 07:04:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11426-03 for <netdev@vger.kernel.org>;
 Mon, 22 Sep 2014 12:04:22 +0100 (BST)
In-Reply-To: <20140919173504.GA4136@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Richard Cochran
> On Thu, Sep 18, 2014 at 06:40:46PM -0400, Alexander Duyck wrote:
> 
> > +static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
> > +			     struct fm10k_mbx_info *mbx)
> > +{
> > +	struct fm10k_intfc *interface = container_of(hw,
> > +						     struct fm10k_intfc,
> > +						     hw);
> 
> This looks really funny to me here and in the other spot. Why not this?
> 
> 	struct fm10k_intfc *interface = container_of(hw, struct fm10k_intfc, hw);
> 
> Its only one over the 80 km/h speed limit.

Or split the assignment from the declaration.

	David
