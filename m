From: David Lang <david.lang@digitalinsight.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 14:10:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.60.0409151407330.21357@dlang.diginsite.com>
References: <4148991B.9050200@pobox.com><Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
 <1095275660.20569.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Paul Jakma <paul@clubi.ie>, Netdev <netdev@oss.sgi.com>,
        leonid.grossman@s2io.com,
        Linux Kernel Mailing List
	 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1095275660.20569.0.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, Alan Cox wrote:

> On Mer, 2004-09-15 at 21:04, Paul Jakma wrote:
>> The intel IXP's are like the above, XScale+extra-bits host-on-a-PCI
>> card running Linux. Or is that what you were referring to with
>> "<cards exist> but they are all fairly expensive."?
>
> Last time I checked 2Ghz accelerators for intel and AMD were quite cheap
> and also had the advantage they ran user mode code when idle from
> network processing.

That depends on how many of these accelerators you already have in the 
system. If you have 4 of them and they are heavily used so that you want 
to offload them it definantly isn't cheap to add a 5th (you useually have 
to go up to 8 or so and the difference between 4 and 8 is frequently 2x-4x 
the cost of the 4 processor box)

now if you start with a single CPU system then yes, adding a second one is 
cheap. but these are useually not the people who really need TOE (they may 
think that they do, but that's a different story :-)

David Lang

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare
