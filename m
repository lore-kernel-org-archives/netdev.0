From: jamal <hadi@cyberus.ca>
Subject: RE: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: 15 Sep 2003 07:37:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063625865.1077.56.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0309121003430.1442-100000@beotest.scyld.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>,
   Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com, ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0309121003430.1442-100000@beotest.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 11:29, Donald Becker wrote:

> Remember the purpose of the driver (hardware) Tx queue.
> It should be the minimum size consistent with
>   Keeping the wire busy(1) when we have queued packets
>   Cache locality(2) when queueing Tx packets
>   Allowing interrupt mitigation
> It is *not* supposed to act as an additional buffer in the system.
> Unlike the queue layer, it cannot be changed dynamically, classify
> packets, re-order based on priority or do any of the future clever
> improvements possible with the general-purpose, device-independent
> software queue. 
> 
> (1) A short gap with atypical traffic is entirely acceptable
> 
> (2) Cache locality isn't important because we need local performance.  It's
>     important to minimize cache line displacement for the rest of the
>     system, especially the application.

Dont know how much time you have, but this would be a good paper if you
wrote one. Since you already have gathered data "in the days when CPUs
were slow", you can complement it with newer data. If you dont have
time, i am sure there are people who will be interested in collecting
data for you.

cheers,
jamal
