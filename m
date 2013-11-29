From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169: check ALDPS bit and disable it if
 enabledforthe 8168g
Date: Fri, 29 Nov 2013 16:17:17 -0500 (EST)
Message-ID: <20131129.161717.572858650800346229.davem@davemloft.net>
References: <39CC8E82FCD4479EAB9EDB7D7F708397@realtek.com.tw>
	<20131128062257.GB9297@linux-g7tt.site>
	<3D20A16DBE2E409ABD3A208B40879CC5@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dchang@suse.com, netdev@vger.kernel.org, romieu@fr.zoreil.com,
	jlee@suse.com, nic_swsd@realtek.com
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab3K2VRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:17:19 -0500
In-Reply-To: <3D20A16DBE2E409ABD3A208B40879CC5@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Thu, 28 Nov 2013 15:58:53 +0800

>  David Chang [mailto:dchang@suse.com] 
>> Sent: Thursday, November 28, 2013 2:23 PM
>> To: Hayeswang
>> Cc: netdev@vger.kernel.org; 'David S. Miller'; 'Francois 
>> Romieu'; jlee@suse.com; nic_swsd
>> Subject: Re: [PATCH net] r8169: check ALDPS bit and disable 
>> it if enabledforthe 8168g
>> 
>> On Thu, Nov 28, 2013 at 01:28:08PM +0800, hayeswang wrote:
>> >  David Chang [mailto:dchang@suse.com] 
>> > > Sent: Thursday, November 28, 2013 12:29 PM
>> > > To: Hayeswang
>> > > Cc: netdev@vger.kernel.org; 'David S. Miller'; 'Francois 
>> > > Romieu'; jlee@suse.com; nic_swsd
>> > > Subject: Re: [PATCH net] r8169: check ALDPS bit and disable 
>> > > it if enabled forthe 8168g
>> > [...]
>> > > > You have to delay at least 10 ms after disable it.
>> > > > This makes sure the hw completes the action.
>> > > >  
>> > > 
>> > > Thanks for your comment. 
>> > > I'd add a delay time and send the v2 version.
>> > 
>> > Excuse me. Our engineers have different opinions about the delay.
>> > I would comfirm it first.
>> >  
>> OK! I'd wait until the final result, thanks!
> 
> The delay is unnecessary. Thanks.
> 
> Acked-by: Hayes Wang <hayeswang@realtek.com>

Applied and queued up for -stable, thanks everyone.
