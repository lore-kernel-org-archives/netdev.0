From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 3/3] stmmac: fix driver Kconfig when built as
 module
Date: Tue, 05 Jun 2012 07:16:56 +0200
Message-ID: <4FCD9648.5030106@st.com>
References: <1338827531-10376-1-git-send-email-peppe.cavallaro@st.com>  <1338827531-10376-4-git-send-email-peppe.cavallaro@st.com> <1338828328.3979.208.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:45499 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754929Ab2FEFRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 01:17:20 -0400
In-Reply-To: <1338828328.3979.208.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/2012 6:45 PM, Ben Hutchings wrote:
> On Mon, 2012-06-04 at 18:32 +0200, Giuseppe CAVALLARO wrote:
>> This patches fixes the driver when built as dyn module.
>> In fact the platform part cannot be built and the probe fails
>> (thanks to Bob Liu that reported this bug).
>>
>> v2: as D. Miller suggested, it is not necessary to make the
>> pci and the platform code mutually exclusive.
>> Having both could also help, at built time ,to verify that
>> all the code is validated and compiles fine.
>>
>> Reported-by: Bob Liu <lliubbo@gmail.com>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> [...]
> 
> What I said in <1337687765.11796.11.camel@deadeye> was:
> 
> That's because CONFIG_STMMAC_PLATFORM and CONFIG_STMMAC_PCI are wrongly
> declared as tristate in Kconfig.  Change them to bool and it should work
> again.
> 
> You can't add a 'Reviewed-by' line on the basis of this; you can only
> add it if a reviewer writes that line themselves (and if you don't make
> further changes).

Thanks, I'm sending the patches again and sorry for the wrong usage of
Reviewed-by.

Peppe

> 
> Ben.
> 
