From: Kovacs Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH] ipv4 tcp autobind problem
Date: Tue, 07 Oct 2003 14:35:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F82B326.9050508@balabit.hu>
References: <200310071156.PAA31530@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jmorris@redhat.com,
        netdev@oss.sgi.com, linux-net@vger.kernel.org,
        Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200310071156.PAA31530@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   Hi,

kuznet@ms2.inr.ac.ru wrote:
> Right place to finish tracking is when socket is removed from TCP
> hash tables, and to start tracking is when the socket is inserted
> to TCP hash tables. BTW you would not see the problem with binding
> if it was made right.

   Thanks for the reply. In the meantime, although because of slightly 
different reasons, we also came to the same conclusion. Right now I'm 
testing a version in which our "unassign" hook is removed from 
inet_release(), and added to udp_v4_unhash() and tcp_put_port().
However, I'm not quite sure there won't be locking problems when calling 
our hook from these places.

-- 
   Regards,
     Krisztian KOVACS
