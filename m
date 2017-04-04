From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] New kernel function to get IP overhead
 on a socket.
Date: Mon, 03 Apr 2017 19:19:19 -0700 (PDT)
Message-ID: <20170403.191919.732158650374501762.davem@davemloft.net>
References: <alpine.DEB.2.11.1704031316390.24947@vera100.eng.brocade.com>
        <20170403.133040.2079781719239791612.davem@davemloft.net>
        <alpine.DEB.2.11.1704031906060.6985@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, kleptog@svana.org, nprachan@brocade.com,
        rshearma@brocade.com, stephen@networkplumber.org,
        sdietric@brocade.com, ciwillia@brocade.com, lboccass@brocade.com,
        dfawcus@brocade.com, bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: parameswaran.r7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1704031906060.6985@vera100.eng.brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Mon, 3 Apr 2017 19:12:20 -0700 (PDT)

> 
> 
> Hi Dave,
> 
> Please see inline:
> 
> On Mon, 3 Apr 2017, David Miller wrote:
> 
>> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
>> Date: Mon, 3 Apr 2017 13:28:11 -0700 (PDT)
>> 
>> > Can I take this to mean that we do need to factor in IP options in 
>> > the L2TP device MTU setup (i.e approach in the posted patch is okay)? 
>> > 
>> > If yes, please let me know if I can keep the socket IP option overhead 
>> > calculations in a generic function, or it would be better to move it back into 
>> > L2TP code? 
>> 
>> If the user creates and maintains this UDP socket, then yes we have to
>> account for potential IP options.
>> 
> 
> Can I take this to mean that the patch in its present form is 
> acceptable (patch currently accounts for IP options on the socket)? 
> Please let me know if any further change is needed (I'll clean up the 
> krobot reported errors after this).

Yes, please respin the patch with the krobot errors fixed.
