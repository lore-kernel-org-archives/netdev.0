From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 16572] random panics in bridging on 2.6.34+
Date: Fri, 18 Mar 2011 15:17:04 -0700 (PDT)
Message-ID: <20110318.151704.91345093.davem@davemloft.net>
References: <20110318081052.6ca134fb@nehalam>
	<20110318152728.GA22053@gondor.apana.org.au>
	<20110318090338.2f6dcb5d@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43770
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932885Ab1CRWQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 18:16:26 -0400
In-Reply-To: <20110318090338.2f6dcb5d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 18 Mar 2011 09:03:38 -0700

> On Fri, 18 Mar 2011 10:27:28 -0500
> Herbert Xu <herbert@gondor.hengli.com.au> wrote:
> 
>> On Fri, Mar 18, 2011 at 08:10:52AM -0700, Stephen Hemminger wrote:
>> > On Fri, 18 Mar 2011 13:49:03 GMT
>> > bugzilla-daemon@bugzilla.kernel.org wrote:
>> > 
>> > > https://bugzilla.kernel.org/show_bug.cgi?id=16572
>> >
>> > Herbert hasn't submitted the patch upstream.
>> 
>> Oops! Thanks for reminding me.
>> 
>> bridge: Reset IPCB when entering IP stack on NF_FORWARD
>> 
>> Whenever we enter the IP stack proper from bridge netfilter we
>> need to ensure that the skb is in a form the IP stack expects
>> it to be in.
>> 
>> The entry point on NF_FORWARD did not meet the requirements of
>> the IP stack, therefore leading to potential crashes/panics.
>> 
>> This patch fixes the problem.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
