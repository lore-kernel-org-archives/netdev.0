From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: RE: [PATCH 2/6] IB: match connection requests
	based on private data
Date: Mon, 06 Mar 2006 11:31:07 -0800
Message-ID: <440C8DFB.7090005@ichips.intel.com>
References: <54AD0F12E08D1541B826BE97C98F99F12FBF19@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F12FBF19@NT-SJCA-0751.brcm.ad.broadcom.com>
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

Caitlin Bestler wrote:
> The term "private data" is intended to convey the
> intent that the data is private to the application
> layer and is opaque to middleware and the network.

The private data area is for the use of whatever client resides above the 
Infiniband CM only.  There is no assumption about whether that client is 
middleware or an application.

> By what mechanism does the listening application
> delegate how much of the private data for use by
> the CM for sub-dividing a listen? What does an 
> application do if it wishes to retain full ownership
> of the private data?

An application that interfaces directly with the Infiniband CM always retains 
full control of any private data.  Applications that interface to middleware are 
restricted by the limitations of that middleware layer.

- Sean
