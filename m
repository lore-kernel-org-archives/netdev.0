From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] net: bridge: add per-port
 unknown multicast flood control
Date: Thu, 01 Sep 2016 22:48:56 -0700 (PDT)
Message-ID: <20160901.224856.296397400865362347.davem@davemloft.net>
References: <1472650612-2123-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1472650612-2123-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed, 31 Aug 2016 15:36:50 +0200

> The first patch prepares the forwarding path by having the exact packet
> type passed down so we can later filter based on it and the per-port
> unknown mcast flood flag introduced in the second patch. It is similar to
> how the per-port unknown unicast flood flag works.
> Nice side-effects of patch 01 are the slight reduction of tests in the
> fast-path and a few minor checkpatch fixes.
> 
> v3: don't change br_auto_mask as that will change user-visible behaviour
> v2: make pkt_type an enum as per Stephen's comment

Series applied, thanks Nikolay.
