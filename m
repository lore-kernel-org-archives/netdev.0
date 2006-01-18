From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Fwd: [PATCH 1 of 3] move destructor to
	struct	neigh_parms
Date: Wed, 18 Jan 2006 23:27:32 +0200
Message-ID: <20060118212732.GA32283@mellanox.co.il>
References: <OFB2D358DB.F7A4CFB5-ON872570FA.007138E4-882570FA.00714019@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	openib-general-bounces@openib.org,
	LKML <linux-kernel@vger.kernel.org>, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Shirley Ma <xma@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFB2D358DB.F7A4CFB5-ON872570FA.007138E4-882570FA.00714019@us.ibm.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Quoting Shirley Ma <xma@us.ibm.com>:
> Subject: Re: Fwd: [PATCH 1 of 3] move destructor to struct neigh_parms
> 
> 
> >+                 if (neigh->parms->neigh_destructor)
> >+                                  (neigh->parms->neigh_destructor)(neigh); 
> 
> Is that safe without checking neigh->parms here?

Yes, we have neigh_parms_put(neigh->parms); a couple of lines below.

-- 
MST
