From: jamal <hadi@cyberus.ca>
Subject: Re: Kernel BUG: Qos seg. fault
Date: 24 May 2004 17:32:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1085434355.1039.47.camel@jzny.localdomain>
References: <20040524212553.52149.qmail@web80507.mail.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jaume Catarineu <jaume.catarineu@upf.edu>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <20040524212553.52149.qmail@web80507.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-05-24 at 17:25, Dmitry Torokhov wrote:

> The only reason TBF has a class is that within current framework 
> net/sched framework child qdisc can only be attached to a class.
> So TBF defines a class (there is only one per TBF qdisc, it's
> created automatically and can not be changed) much like sch_prio
> does. The difference is that sch_prio can have up to TCQ_PRIO_BANDS
> children so implementing filters for sch_prio makes sense. TBF has
> one and only one child qdisc. It starts with noop_qdisc from
> sch_generic and later user can change to to something else, like
> original poster did.
>
> Since TBF has only one child no matter what I contend that 
> implementing filters for TBF does not make sense, filters should
> be attached either to TBF's child ot to TBF's parent but not to
> TBF itself.

Ok, understood. Why does TBF have only one child? 

cheers,
jamal

PS:- Very strange how netdev is not allowing my postings through.
