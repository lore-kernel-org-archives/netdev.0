From: "Mala Anand" <manand@us.ibm.com>
Subject: Re: Network oops
Date: Wed, 12 Jun 2002 11:58:30 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae7upu$je2$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, linux-net-owner@vger.kernel.org,
   netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
List-Id: netdev.vger.kernel.org

>> On Mon, 10 Jun 2002, Mala Anand wrote:

>>  I have seen this problem with this NIC.  You need to increase
>> the number of buffers in the RX and TX ring in eepro100.c file.
>> Right now it is set to 32, change it to 256 or 128 this error
>> will go away.

> Donald Becker wrote:
>Changing the Tx queue size or number of Rx skbuffs waiting to be filled
>will not fix a problem.  It might mask some problem e.g. a temporary
>shortage of skbuffs, but it doesn't fix anything.

The problem what I saw was resource problem and as a result I had packet
drops.  The
input rate was high and the driver didn't have enough resources to handle.
It was a pure resource problem.
--

Regards,
    Mala


   Mala Anand
   E-mail:manand@us.ibm.com
   Linux Technology Center - Performance
   Phone:838-8088; Tie-line:678-8088
