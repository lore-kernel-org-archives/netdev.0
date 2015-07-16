From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: multicast: treat igmpv3 report
 with INCLUDE and no sources as a leave
Date: Wed, 15 Jul 2015 17:10:57 -0700 (PDT)
Message-ID: <20150715.171057.1821073433510335063.davem@davemloft.net>
References: <1436790517-30266-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.apana.org.au
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1436790517-30266-1-git-send-email-nikolay@cumulusnetworks.com>
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
Date: Mon, 13 Jul 2015 05:28:37 -0700

> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> A report with INCLUDE/Change_to_include and empty source list should be
> treated as a leave, specified by RFC 3376, section 3.1:
> "If the requested filter mode is INCLUDE *and* the requested source
>  list is empty, then the entry corresponding to the requested
>  interface and multicast address is deleted if present.  If no such
>  entry is present, the request is ignored."
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
