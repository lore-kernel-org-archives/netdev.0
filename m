From: shemminger@osdl.org
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 16:01:33 -0800 (PST)
Message-ID: <61814.63.170.215.71.1109635293.squirrel@www.osdl.org>
References: <20050224155906.73890361@dxpl.pdx.osdl.net><20050227202011.5ccefb22.davem@davemloft.net><42235114.3070109@osdl.org>
    <20050228153228.0c5cb46d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>, mostrows@speakeasy.net,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
In-Reply-To: <20050228153228.0c5cb46d.davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Mon, 28 Feb 2005 09:12:52 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
>
>> The original sk98lin attempted to receive hardware checksumming
>> but never actually turned it on.
>
> Because there is a bug in the chip wherein checksums can be
> miscalculated.  I forget the details, but I do remember that
> you can't enable checksumming safely because of this.
>
> In drivers/net/sk98lin/skcsum.c it mentions this:
>
>  * Note:
>  *      There is a bug in the GENESIS ASIC which may lead to wrong
> checksums.
>
> I know this comment is above the send checksum routine, but I
> am pretty sure the bug applies to both directions.

The driver covers two types of chips (Genesis and Yukon). The new
driver only allows receive checksum on Yukon chipset. Almost all
current hardware uses Yukon and it has been pretty well tested.
The issues the sk98lin had were sloppy coding and handling of
unsigned arithmetic.
