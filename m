From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] e100: use NAPI mode all the time (fwd)
Date: 08 Jun 2004 08:30:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086697812.1035.60.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0406072341430.2832@fcat>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc Herbert <marc.herbert@free.fr>
In-Reply-To: <Pine.LNX.4.58.0406072341430.2832@fcat>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-06-08 at 04:50, Marc Herbert wrote:
> On Fri, 4 Jun 2004, Scott Feldman wrote:
> 
> > I see no reason to keep the non-NAPI option for e100.  This patch removes
> > the CONFIG_E100_NAPI option and puts the driver in NAPI mode all the time.
> > Matches the way tg3 works.
> >
> > Unless someone has a really good reason to keep the non-NAPI mode, this
> > should go in for 2.6.7.
> 
> Scott,
> 
>  If I understand pre-NAPI history correctly (please anyone correct
> me), the rationale/reason for the old, "backlog" SW FIFO design was to
> cope with network bursts in the following context:
> 
> (1) transient network throughput higher than what the CPU could
>     manage
> (2) number of RxDescriptors (i.e., FIFO available to the NIC) too
>     small to cope with this burst on the NIC.

The idea with the backlog queue is to defer work i.e the concept being a
very little time time spent in high priority portions (such as inteupts.
So nothing to do with any of the above as far as i know.

cheers,
jamal
