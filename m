From: rick jones <rick.jones2@hp.com>
Subject: Re: RFC 1323
Date: Mon, 4 Apr 2005 09:56:06 -0700
Message-ID: <eec5edbe5aa5c2ba81c0ad8297b900f9@hp.com>
References: <BAY20-F2375830DACBEC22EDD913C923B0@phx.gbl>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <BAY20-F2375830DACBEC22EDD913C923B0@phx.gbl>
To: "R Harper" <rharper333@hotmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>
> Another question,  as I understand the RFC, the timestamp are only 
> relevant to the box generating them. Are TCP implementation different 
> in how the TSval data is represented?

They certainly can be - for the PAWS portion of 1323 the fields in the 
"timestamp" options only have to be monotonic nondecreasing so they can 
extend the sequence number space.  From my brief perusal of the RFC, 
sender's are free to have them be more or less whatever they want, and 
as networks become faster (10G) looks like higher resolution will be 
desired.

[I wonder when even the extra 32 bits will not be enough :) ]

With the recent dust-up about ID'ing systems based on their clock skew, 
it would not surprise me to see someone suggest that the options should 
just be for PAWS and not for RTTM.

> Is it possible to make use of the timestamp in an intermediate box, 
> e.g. estimating RTT in a box that a TCP connection passes?

If you know that the sender is using the option for timing, and know 
the resolution - basically that means knowing what the sender is 
running.

rick jones
there is no rest for the wicked, yet the virtuous have no pillows
