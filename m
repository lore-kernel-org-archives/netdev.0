From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: sctp snmp mib stats in /proc/net/snmp
Date: Tue, 29 Oct 2002 09:32:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DBEC628.75396DA@us.ibm.com>
References: <Pine.LNX.4.44.0210290912580.3213-100000@w-nivedita.beaverton.ibm.com> <20021029.091823.121274899.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: Nivedita Singhvi <niv@us.ibm.com>
>    Date: Tue, 29 Oct 2002 09:21:40 -0800 (PST)
> 
>    Ah, sorry about that, and thanks for the
>    tip :). Will do next time..For now, here is
>    the plain diff.
> 
> Where will sctp_statistics be defined?  If it will be in net/sctp/*.c,
> then you will need to ifdef this ipv4 procfs code on CONFIG_IP_SCTP

Rats, yes, it is in net/sctp/protocol.c. I'll move it under the ifdef
and make up a complete patch with the dependent code for review
purposes and repost. Thanks for the catch!

thanks,
Nivedita
