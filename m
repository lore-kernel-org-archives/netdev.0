From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 21:20:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF6DA8E51.7C3572D3-ON85256D9F.000B88F1-86256D9F.000CB34F@us.ibm.com>
References: <1063330463.1028.8.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1063330463.1028.8.camel@jzny.localdomain>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jamal wrote:

>* increase instead the txquelen (as suggested by Davem); user space
>tools like ip or ifconfig could do it. The standard size has been around
>100 for 100Mbps; i suppose it is fair to say that Gige can move data out
>at 10x that; so set it to 1000. Maybe you can do this from the driver
>based on what negotiated speed is detected?

      This is also another way to do it. As long as we make it harder for
users to drop packets and get up to date with Gigabit speeds. We would also
have to think about the upcomming 10Gige adapters and their queue sizes,
but that is a separate issue. Anyway, the driver can easly set the
txqueuelen to 1000.

      We should care about counting the packets being dropped on the
transmit side. Would it be the responsability of the driver to account for
this drops? Because each driver has a dedicated software queue and in my
opinion, the driver should account for this packets.


regards,


----------------------------------------------------------------------------------

***  ALWAYS THINK POSITIVE ***
