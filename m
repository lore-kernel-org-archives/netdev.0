From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: allow disabling multilink protocol ID compression
Date: Tue, 28 Dec 2010 13:53:55 -0800 (PST)
Message-ID: <20101228.135355.115924746.davem@davemloft.net>
References: <20101220195833.26786ec5@nehalam>
	<20101221224400.GA17383@brick.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20101221224400.GA17383@brick.ozlabs.ibm.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Wed, 22 Dec 2010 09:44:00 +1100

> On Mon, Dec 20, 2010 at 07:58:33PM -0800, Stephen Hemminger wrote:
> 
>> Linux would not connect to other router running old version Cisco IOS (12.0).
>> This is most likely a bug in that version of IOS, since it is fixed
>> in later versions. As a workaround this patch allows a module parameter
>> to be set to disable compressing the protocol ID.
>> 
>> See: https://bugzilla.vyatta.com/show_bug.cgi?id=3979
>> 
>> RFC 1990 allows an implementation to formulate MP fragments as if protocol
>> compression had been negotiated.  This allows us to always send compressed
>> protocol IDs.  But some implementations don't accept MP fragments with
>> compressed protocol IDs.  This parameter allows us to interoperate with
>> them.  The default value of the configurable parameter is the same as the
>> current behavior:  protocol compression is enabled.  If protocol compression
>> is disabled we will not send compressed protocol IDs.
>> 
>> This is based on an earlier patch by Bob Gilligan (using a sysctl).
>> Module parameter is writable to allow for enabling even if ppp
>> is already loaded for other uses.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Paul Mackerras <paulus@samba.org>

Applied, thanks.
