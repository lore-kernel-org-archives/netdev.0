From: rick jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same yes?
Date: Sat, 22 Jan 2005 10:58:54 -0800
Message-ID: <A96F0D40-6CA7-11D9-86F8-000393765F60@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com> <41F163AD.5070400@hp.com> <20050121124441.76cbbfb9.davem@davemloft.net> <41F17B7E.2020002@hp.com> <20050121141820.7d59a2d1.davem@davemloft.net> <41F186A8.9030805@hp.com> <41F18927.5020607@hp.com> <20050121204418.2070d76d.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050121204418.2070d76d.davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Jan 21, 2005, at 8:44 PM, David S. Miller wrote:

> On Fri, 21 Jan 2005 14:58:47 -0800
> Rick Jones <rick.jones2@hp.com> wrote:
>
>> Speaking of divisor values... is zero (0) supposed to be a legal 
>> value?  The
>> sysctl seems to allow it but it does seem to behave a triffle 
>> strangely.  The
>> initial TSO size appeared to be 2MSS.
>
> The value "0" behaves the same as "1".

Alas I'm away from my traces at the moment, but I do recall seeing 
different behaviour with 0 than with one - with one the TSO sends 
started at 3*1448, with the divisor at zero they started at what 
appeared to be 2*1448.

I'll see if I can get to the traces before monday and send them along.

rick jones
there is no rest for the wicked, yet the virtuous have no pillows
