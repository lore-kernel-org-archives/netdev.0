From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Tue, 13 Nov 2007 08:41:09 -0800
Message-ID: <4739D3A5.4020503@intel.com>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
	<20071113.033611.73195922.davem@davemloft.net>
	<20071113120328.GB1086@gondor.apana.org.au>
	<20071113.040624.43544149.davem@davemloft.net>
	<20071113121647.GA1330@gondor.apana.org.au>
	<4739961E.90708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com,
	David Miller <davem@davemloft.net>, cfriesen@nortel.com, w@1wt.eu
To: Patrick McHardy <kaber@trash.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4739961E.90708@trash.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Herbert Xu wrote:
>> On Tue, Nov 13, 2007 at 04:06:24AM -0800, David Miller wrote:
>>>> In other words we can make it so that nobody is in promiscuous
>>>> mode and therefore have to disable VLAN acceleration *unless*
>>>> they really want to be in that state.  In which case it would
>>>> imply that they wish to see everything and therefore we should
>>>> disable VLAN acceleration.
>>> This is too complicated, we have multiple unicast MAC support
>>> in the driver API already, let's simply use it.
>>
>> Yes I agree.  People not using Patrick's new API deserves to
>> get poor performance so they can switch over sooner :)
>>
>> What I was trying to say above is that e1000 currently uses
>> the old set_multicast_list interface (rather than dev_set_rx_mode)
>> so it's not immediately obvious why we're in promiscuous mode.
>> We could look at dev->promiscuity - !!uc_count but that feels a
>> bit fragile.
>>
>> Perhaps those who want to push this patch should be encouraged
>> to convert e1000 to the new interface :)
> 
> 
> I already posted a patch for this, not sure what happened to it.
> Auke, any news on merging the secondary unicast address support?

I dropped the ball on that one. Care to resend it and send me one for e1000e as well?

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
