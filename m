From: "David S. Miller" <davem@redhat.com>
Subject: Re: sctp snmp mib stats in /proc/net/snmp
Date: Tue, 29 Oct 2002 09:18:23 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029.091823.121274899.davem@redhat.com>
References: <Pine.LNX.4.44.0210290912580.3213-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <Pine.LNX.4.44.0210290912580.3213-100000@w-nivedita.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Tue, 29 Oct 2002 09:21:40 -0800 (PST)
   
   Ah, sorry about that, and thanks for the
   tip :). Will do next time..For now, here is 
   the plain diff.
   
Where will sctp_statistics be defined?  If it will be in net/sctp/*.c,
then you will need to ifdef this ipv4 procfs code on CONFIG_IP_SCTP
