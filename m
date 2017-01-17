From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [patch net-next] stmmac: indent an if statement
Date: Tue, 17 Jan 2017 09:25:21 +0100
Message-ID: <4902e86a-6a86-57d6-51c2-55e391b83dc3@st.com>
References: <20170112184631.GA12157@mwanda>
 <20170115.221438.1956356112755181222.davem@davemloft.net>
 <20170116091924.GA4104@mwanda> <20170116093954.GB4104@mwanda>
 <alpine.DEB.2.20.1701162240100.2031@hadrien> <20170116215615.GG4104@mwanda>
 <alpine.DEB.2.20.1701162308540.2031@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <peppe.cavallaro@st.com>,
        <Joao.Pinto@synopsys.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>,
        Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1701162308540.2031@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julia

On 01/16/2017 11:10 PM, Julia Lawall wrote:
>
>
> On Tue, 17 Jan 2017, Dan Carpenter wrote:
>
>> On Mon, Jan 16, 2017 at 10:46:22PM +0100, Julia Lawall wrote:
>>>
>>>
>>> On Mon, 16 Jan 2017, Dan Carpenter wrote:
>>>
>>>> On Mon, Jan 16, 2017 at 12:19:24PM +0300, Dan Carpenter wrote:
>>>>> On Sun, Jan 15, 2017 at 10:14:38PM -0500, David Miller wrote:
>>>>>> From: Dan Carpenter <dan.carpenter@oracle.com>
>>>>>> Date: Thu, 12 Jan 2017 21:46:32 +0300
>>>>>>
>>>>>>> The break statement should be indented one more tab.
>>>>>>>
>>>>>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>>>>
>>>>>> Applied, but like Julia I think we might have a missing of_node_put()
>>>>>> here.
>>>>>
>>>>> Of course, sorry for dropping the ball on this.  I'll send a patch for
>>>>> that.
>>>>>
>>>>
>>>> Actually, I've looked at it some more and I think this function is OK.
>>>> We're supposed to do an of_node_put() later...  I can't find where that
>>>> happens, but presumably that's because I don't know stmmac well.  This
>>>> code here, though, is fine.
>>>
>>> Why do you think it is fine?  Does anyone in the calling context know
>>> which child would have caused the break?
>>
>> Yeah.  It's saved in plat->mdio_node and we expect to be holding on
>> either path through the function.
>>
>> (It would be better if one of the stmmac people were responding here
>> insead of a random fix the indenting weenie like myself.)
>
> OK, I agree that there should not be an of_node_put with the break.
>
> Perhaps there should be an of_node_put on plat->mdio_node in
> stmmac_remove_config_dt, like there is an of_node_put on plat->phy_node.
> But it would certainly be helpful to hear from someone who knows the code
> better.

I also think it's missing! Can you propose a patch ?

br
Alex

>
> julia
>
