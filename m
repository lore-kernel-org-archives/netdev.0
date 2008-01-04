From: Rolf Manderscheid <rvm@obsidianresearch.com>
Subject: [ofa-general] Re: [RFC PATCH] IPoIB: improve IPv4/IPv6 to IB mcast
	mapping functions
Date: Fri, 04 Jan 2008 16:59:53 -0700
Message-ID: <477EC879.7010501@obsidianresearch.com>
References: <20071210203544.GI30090@obsidianresearch.com>	<20071210203841.GJ30090@obsidianresearch.com>
	<adair29mel2.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adair29mel2.fsf_-_@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> Any objection to merging the following for 2.6.25?
>
> [Rolf -- I think it makes more sense to delete the overwriting of the
> P_Key in ipoib_multicast.c in this patch rather than later in the
> series; do you agree?]
>   
Yes, the first patch is the logical place for it.  The only reason
I put it in the second patch was to keep the first patch as small
and simple as possible.

    Rolf
