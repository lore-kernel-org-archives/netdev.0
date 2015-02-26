From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to
 traverse the bridge without hitting netfilter
Date: Thu, 26 Feb 2015 11:34:31 -0500 (EST)
Message-ID: <20150226.113431.238255529591339000.davem@davemloft.net>
References: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com>
	<20150223160619.GF24297@breakpoint.cc> <54EEF32D.2010202@amazon.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, fw@strlen.de,
	imrep.amz@gmail.com, linux-kernel@vger.kernel.org, aliguori@amazon.com
To: imrep@amazon.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <54EEF32D.2010202@amazon.de>
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

From: Imre Palik <imrep@amazon.de>
Date: Thu, 26 Feb 2015 11:19:25 +0100

> If you are looking for peculiarities in my setup then here they are:
> I am on 4k pages, and perf is not working :-(
> (I am trying to fix those too, but that is far from being a low hanging fruit.)
> So my guess would be that the packet pipeline doesn't fit in the cache/tlb

Pure specualtion until you can actually use perf to measure these
things.

And I don't want to apply patches which were designed based upon
pure speculation.
