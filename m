From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch 2.6.11] bonding: avoid tx balance for IGMP (alb/tlb mode)
Date: Tue, 15 Mar 2005 16:52:14 -0800
Message-ID: <4237833E.9080809@hp.com>
References: <20050315215128.GA18262@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ctindel@users.sourceforge.net,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@oss.sgi.com, jgarzik@pobox.com
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20050315215128.GA18262@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is that switch behaviour "normal" or "correct?"  I know next to nothing about 
what stuff like LACP should do, but asked some internal folks and they had this 
to say:

<excerpt>


<blank> treats IGMP packets the same as all other non-broadcast traffic (i.e. it
will attempt to load balance). This switch behavior seems rather odd in an
aggregated case, given the fact that most traffic (except broadcast packets)
will be load balanced by the partner device. In addition, the switch (in
theory) is suppose to treat the aggregated switch ports as 1 logical port
and therefore it should allow IGMP packets to be received back on any port
in the logical aggregation.

IMO, the switch behavior in this case seems questionable.

</excerpt>

FWIW,

rick jones
