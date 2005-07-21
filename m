From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Thu, 21 Jul 2005 20:20:35 +0200
Message-ID: <1121970035.5904.6.camel@notepaq>
References: <20050717220451.GB13434@rama.risq.ericsson.ca>
	<20050718.203145.105430424.davem@davemloft.net>
	<20050720132305.GA4077@rama>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050720132305.GA4077@rama>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi Harald,

> I just ran into Marcel Holtmann earlier today.  He thinks moving that
> data into the cb is fine, though he has to double-check that.
> 
> He also said that he really only needs 5 bits, so even if the current
> pkt_type overloading would persist, we could probably shrink it to make
> space for the IPVS bit.

please forget about the 5 bits thingy, I told you. Splitting it up into
bitlevel will screw up the HCI filter completly. However after a look
trough the Bluetooth core it should be quite easy too move the pkt_type
into the control buffer. We already use it for a direction bit. The
nasty thing is that I have to modify all the drivers. So when you
finally decided to shrink the pkt_type, I think that I can come up with
a patch for it quiet quickly.

Regards

Marcel
