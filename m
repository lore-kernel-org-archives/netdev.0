From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 9 Jan 2007 10:29:12 -0800
Message-ID: <54AD0F12E08D1541B826BE97C98F99F1EE6B67@NT-SJCA-0751.brcm.ad.broadcom.com>
References: <20070109135725.GF16107@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>,
	"openib-general" <openib-general@openib.org>,
	linux-kernel@vger.kernel.org,
	"Divy Le Ray" <divy@chelsio.com>
Return-path: <openib-general-bounces@openib.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070109135725.GF16107@mellanox.co.il>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>,
	"Steve Wise" <swise@opengridcomputing.com>
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

 

> -----Original Message-----
> From: openib-general-bounces@openib.org 
> [mailto:openib-general-bounces@openib.org] On Behalf Of 
> Michael S. Tsirkin
> Sent: Tuesday, January 09, 2007 5:57 AM
> To: Steve Wise
> Cc: netdev@vger.kernel.org; Roland Dreier; Divy Le Ray; 
> linux-kernel@vger.kernel.org; openib-general
> Subject: Re: [openib-general] [PATCH 1/10] cxgb3 - main header files
> 
> > We also need to decide on the ib_req_notify_cq() issue.  
> 
> Let's clarify - do you oppose doing copy_from_user from a 
> fixed address passed in during setup?
> 
> If OK with you, this seems the best way as it is the least 
> controversial and least disruptive one.
> 
To clarfiy my understanding of this issue:

A device MAY implement ib_req_notify_cq by updating
a location directly from user mode. Any of the techniques
that apply to other user allocated objects, such as 
the Send Queue, can be applied here.

Even those the proposed changes would be about as
low impact and benign as possible, the fact that there
are valid solutions without an API changes leans heavily
towards using those solutions.
