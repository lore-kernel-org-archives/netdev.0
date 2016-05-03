From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Tue, 3 May 2016 15:41:57 +0300
Message-ID: <57289C95.8030401@mellanox.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
 <20160429224333.12418.13862.stgit@ahduyck-xeon-server>
 <CAJ3xEMiog9zEwg_S=jG5LjM6FpvtyffvPcYX_G4j-ubBE_wLDw@mail.gmail.com>
 <CAKgT0UdV2ruuRsYLmOjnqbXW0_i4QqMfo+VhuCSBqJjWrKhRdQ@mail.gmail.com>
 <CAJ3xEMj_Vez_pP0ZTVATR=AMNDF1fneZ3dVrfWT7NP1mj4APRQ@mail.gmail.com>
 <CAKgT0UdeuJA-K8zim5Eact9A2oFscXDC2a7ciKGTo74xptuw4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <michael.chan@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	"Eran Ben Elisha" <eranbe@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0088.outbound.protection.outlook.com ([157.55.234.88]:7534
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932687AbcECMmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 08:42:07 -0400
In-Reply-To: <CAKgT0UdeuJA-K8zim5Eact9A2oFscXDC2a7ciKGTo74xptuw4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2016 6:41 PM, Alexander Duyck wrote:
>> >Just one more piece to clarify... in the general case (e.g inner
>> >packet size 1.5k...64k), the last segment would not have the same
>> >length as the other segments, what happens on that case?
> Actually in the case of GSO partial we have go through the software
> segmentation code and trim off any last bit that doesn't match the MSS
> of the rest of the frame.  That way you end up with one frame that has
> some number of MSS sized chunks, and then one remainder if there is a
> frame that would be a different size.

OK, thanks for further clarifying this, will look on the docs you 
pointed etc. From what you wrote here I understand it's indeed possible 
for one frame to be of different size from the rest, but the LCO thing 
still works somehow..

Or.
