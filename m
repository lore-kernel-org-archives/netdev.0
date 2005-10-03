From: Hal Rosenstock <halr@voltaire.com>
Subject: Re: [PATCH] netdevice.h: Add RDMA private pointer
	to the net_device structure
Date: 03 Oct 2005 17:50:21 -0400
Message-ID: <1128375898.4397.389.camel@hal.voltaire.com>
References: <1128365323.4397.38.camel@hal.voltaire.com>
	<52fyri9tnf.fsf@cisco.com> <1128374816.4397.343.camel@hal.voltaire.com>
	<523bni9tck.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <523bni9tck.fsf@cisco.com>
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

On Mon, 2005-10-03 at 17:35, Roland Dreier wrote:
>     Hal> We will have this shortly. I have been waiting for this to
>     Hal> propose the changes to SDP et al.
> 
> OK, but I don't think it makes sense to merge this upstream until
> there is in-tree code that will use it.

I wanted to get this in so I could add the code to IPoIB to use this so SDP
and others no longer poke at IPoIB's private data. This is a small
change. Should this change be made locally (in OpenIB) first (and we'll
have our own modified netdevice.h for a short time) ?

-- Hal
