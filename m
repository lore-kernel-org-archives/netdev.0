From: Jaume Catarineu <jaume.catarineu@upf.edu>
Subject: Re: Kernel BUG: Qos seg. fault (part II)
Date: Tue, 25 May 2004 13:09:52 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B345A0.8080801@upf.edu>
References: <20040524215346.73109.qmail@web80501.mail.yahoo.com><1085436571.	1041.69.camel@jzny.localdomain>  <40B2BD99.4000500@upf.edu> <1085450901.1043.4.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor_core@ameritech.net>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1085450901.1043.4.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Use Dmitry's patch. I believe it would fix the above too.
> You should get an EINVAL error unless you specify the correct
> child id (such as tc filter show dev lo parent 20: )

The patch works with kernel 2.6.4 (also for 2.4.25), and solves the two 
segmentations faults. :)

Jaume,
